$repoRoot = Split-Path -Path $PSScriptRoot -Parent | Split-Path -Parent
$coreModule = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath 'STCore/STCore.psd1'
Import-Module $coreModule -ErrorAction SilentlyContinue
$configFile = Join-Path $repoRoot 'config/supporttools.json'
$SupportToolsConfig = Get-STConfig -Path $configFile
if (-not $SupportToolsConfig.ContainsKey('maintenanceMode')) {
    $SupportToolsConfig.maintenanceMode = $false
}
if ($SupportToolsConfig.maintenanceMode) {
    Write-STStatus -Message 'SupportTools is currently in maintenance mode. Exiting.' -Level WARN -Log
    exit 1
}

function Sanitize-STMessage {
    [CmdletBinding(PositionalBinding=$false)]
    param(
        [Parameter(Mandatory)][string]$Message
    )
    $sanitized = $Message
    # mask email addresses
    $sanitized = [regex]::Replace($sanitized,'[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}','[REDACTED]')
    # mask key=value or token patterns
    $sanitized = [regex]::Replace($sanitized,'(?i)(apikey|token|password|secret|pwd|key)[=:]\s*([^\s]+)','$1=[REDACTED]')
    # mask long random strings that may be secrets
    $sanitized = [regex]::Replace($sanitized,'[A-Za-z0-9+/]{20,}','[REDACTED]')
    return $sanitized
}

function Write-STLog {
    [CmdletBinding(DefaultParameterSetName='Message', PositionalBinding=$false)]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'Message')]
        [ValidateNotNullOrEmpty()]
        [string]$Message,
        [Parameter(Mandatory = $false)]
        [ValidateSet('INFO','WARN','ERROR')]
        [ValidateNotNullOrEmpty()]
        [string]$Level = 'INFO',
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,
        [Parameter(Mandatory = $false)]
        [hashtable]$Metadata,
        [Parameter(Mandatory = $false)]
        [switch]$Structured,
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$ForwardUri,
        [Parameter(Mandatory = $true, ParameterSetName = 'Metric')]
        [ValidateNotNullOrEmpty()]
        [string]$Metric,
        [Parameter(Mandatory = $true, ParameterSetName = 'Metric')]
        [ValidateNotNullOrEmpty()]
        [double]$Value,
        [Parameter(Mandatory = $false)]
        [ValidateRange(1,[int]::MaxValue)]
        [int]$MaxSizeMB = 1,
        [Parameter(Mandatory = $false)]
        [ValidateRange(1,[int]::MaxValue)]
        [int]$MaxFiles = 1
    )
    if ($PSCmdlet.ParameterSetName -eq 'Metric') {
        if (-not $Metadata) { $Metadata = @{} }
        $Metadata.metric = $Metric
        $Metadata.value  = $Value
        $Message = $Metric
        if (-not $Structured) { $Structured = $true }
    }
    $Message = Sanitize-STMessage -Message $Message
    if (-not $Structured -and $env:ST_LOG_STRUCTURED -eq '1') {
        $Structured = $true
    }
    $userProfile = if ($env:USERPROFILE) { $env:USERPROFILE } else { $env:HOME }
    if ($Path) {
        $logFile = $Path
    } elseif ($env:ST_LOG_PATH) {
        $logFile = $env:ST_LOG_PATH
    } else {
        $logDir = Join-Path $userProfile 'SupportToolsLogs'
        $logFile = Join-Path $logDir 'supporttools.log'
    }
    if (-not $ForwardUri -and $env:ST_LOG_FORWARD_URI) { $ForwardUri = $env:ST_LOG_FORWARD_URI }
    Write-STDebug "Logging to $logFile"
    $dir = Split-Path -Path $logFile -Parent
    if (-not (Test-Path $dir)) {
        New-Item -Path $dir -ItemType Directory -Force | Out-Null
    }
    if ($PSBoundParameters.ContainsKey('MaxSizeMB')) {
        $maxBytes = [int64]($MaxSizeMB * 1MB)
    } elseif ($env:ST_LOG_MAX_BYTES) {
        $maxBytes = [int64]$env:ST_LOG_MAX_BYTES
    } else {
        $maxBytes = 1MB
    }
    if (Test-Path $logFile) {
        $currentBytes = (Get-Item $logFile).Length
        if ($currentBytes -gt $maxBytes) {
            for ($i = $MaxFiles; $i -ge 1; $i--) {
                $old = "$logFile.$i"
                $new = "$logFile." + ($i + 1)
                if (Test-Path $old) {
                    if ($i -eq $MaxFiles) { Remove-Item $new -Force -ErrorAction SilentlyContinue }
                    Rename-Item -Path $old -NewName $new -Force
                }
            }
            try {
                Rename-Item -Path $logFile -NewName "$logFile.1" -Force
            } catch {
                Write-STDebug "Failed to rotate log: $_"
            }
        }
    }
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $user = if ($env:USERNAME) { $env:USERNAME } else { $env:USER }
    $stack  = Get-PSCallStack
    $caller = $stack | Where-Object { $_.InvocationInfo.MyCommand.Name -notin 'Write-STLog','Write-STStatus' } | Select-Object -First 1
    $module = $null
    if ($caller) {
        $module = $caller.InvocationInfo.MyCommand.ModuleName
        if (-not $module) { $module = Split-Path -Leaf $caller.InvocationInfo.PSCommandPath }
    }
    if (-not $module) { $module = 'Unknown' }
    if ($Structured) {
        $entry = [ordered]@{
            timestamp = $timestamp
            module    = $module
            user      = $user
            level     = $Level
            message   = $Message
        }
        if ($Metadata) { foreach ($k in $Metadata.Keys) { $entry[$k] = $Metadata[$k] } }
        $json = $entry | ConvertTo-Json -Compress
        $json | Out-File -FilePath $logFile -Append -Encoding utf8
        if ($ForwardUri) {
            try {
                Invoke-RestMethod -Uri $ForwardUri -Method Post -Body $json -ContentType 'application/json' | Out-Null
            } catch {
                Write-STDebug "Failed to forward log to $ForwardUri: $_"
            }
        }
    } else {
        "$timestamp [$module] [$user] [$Level] $Message" | Out-File -FilePath $logFile -Append -Encoding utf8
    }
}

# Writes a structured JSON log entry following a common schema.
function Write-STRichLog {
    [CmdletBinding(PositionalBinding=$false)]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Tool,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Status,
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$User,
        [Parameter(Mandatory = $false)]
        [timespan]$Duration,
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Details,
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )

    $userProfile = if ($env:USERPROFILE) { $env:USERPROFILE } else { $env:HOME }
    if ($Path) {
        $logFile = $Path
    } elseif ($env:ST_LOG_PATH) {
        $logFile = $env:ST_LOG_PATH
    } else {
        $logDir = Join-Path $userProfile 'SupportToolsLogs'
        $logFile = Join-Path $logDir 'supporttools.log'
    }
    $dir = Split-Path -Path $logFile -Parent
    if (-not (Test-Path $dir)) {
        New-Item -Path $dir -ItemType Directory -Force | Out-Null
    }

    $entry = [ordered]@{
        timestamp = (Get-Date).ToString('o')
        tool      = $Tool
        status    = $Status
    }
    if ($PSBoundParameters.ContainsKey('User'))     { $entry.user = Sanitize-STMessage -Message $User }
    if ($PSBoundParameters.ContainsKey('Duration')) { $entry.duration = $Duration.ToString() }
    if ($PSBoundParameters.ContainsKey('Details'))  {
        $entry.details = @()
        foreach ($d in $Details) { $entry.details += Sanitize-STMessage -Message $d }
    }

    ($entry | ConvertTo-Json -Depth 5 -Compress) | Out-File -FilePath $logFile -Append -Encoding utf8
}

function Write-STStatus {
    [CmdletBinding(PositionalBinding=$false)]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Message,
        [Parameter(Mandatory = $false)]
        [ValidateSet('INFO','SUCCESS','ERROR','WARN','SUB','FINAL','FATAL')]
        [ValidateNotNullOrEmpty()]
        [string]$Level = 'INFO',
        [Parameter(Mandatory = $false)]
        [switch]$Log
    )

    switch ($Level) {
        'SUCCESS' { $prefix = '[+]'; $color = 'Green' }
        'ERROR'   { $prefix = '[-]'; $color = 'Red' }
        'WARN'    { $prefix = '[!]'; $color = 'Yellow' }
        'SUB'     { $prefix = '[>]'; $color = 'DarkCyan' }
        'FINAL'   { $prefix = '[✔]'; $color = 'Green' }
        'FATAL'   { $prefix = '[✘]'; $color = 'Red' }
        default   { $prefix = '[*]'; $color = 'Cyan' }
    }

    Write-Host "$prefix $Message" -ForegroundColor $color
    if ($Log) { Write-STLog -Message "$prefix $Message" -Structured:$($env:ST_LOG_STRUCTURED -eq '1') }
}

function Show-STPrompt {
    [CmdletBinding(PositionalBinding=$false)]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Command,
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$Path = (Get-Location).Path
    )
    $user = if ($env:USERNAME) { $env:USERNAME } else { $env:USER }
    $host = if ($env:COMPUTERNAME) { $env:COMPUTERNAME } else { $env:HOSTNAME }
    Write-Host "┌──($user@$host)-[$Path]" -ForegroundColor DarkGray
    Write-Host "└─$ $Command" -ForegroundColor Gray
}

function Write-STDivider {
    [CmdletBinding(PositionalBinding=$false)]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Title,
        [Parameter(Mandatory = $false)]
        [ValidateSet('light','heavy')]
        [ValidateNotNullOrEmpty()]
        [string]$Style = 'light'
    )
    $char = if ($Style -eq 'heavy') { '═' } else { '─' }
    $total = 65
    $padding = $total - $Title.Length - 4
    if ($padding -lt 0) { $padding = 0 }
    $half = [math]::Floor($padding / 2)
    $divider = ($char * $half) + "[ $Title ]" + ($char * ($padding - $half))
    Write-Host $divider -ForegroundColor DarkGray
}

function Write-STBlock {
    [CmdletBinding(PositionalBinding=$false)]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [hashtable]$Data
    )
    $max = ($Data.Keys | Measure-Object -Property Length -Maximum).Maximum
    foreach ($k in $Data.Keys) {
        $label = ($k + ':').PadRight($max + 1)
        Write-Host "> $label $($Data[$k])" -ForegroundColor Gray
    }
}

function Write-STClosing {
    [CmdletBinding(PositionalBinding=$false)]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$Message = 'Task Complete'
    )
    Write-Host "┌──[ $Message ]──────────────" -ForegroundColor DarkGray
}

Export-ModuleMember -Function 'Write-STLog','Write-STRichLog','Write-STStatus','Show-STPrompt','Write-STDivider','Write-STBlock','Write-STClosing','Sanitize-STMessage'

function Show-LoggingBanner {
    <#
    .SYNOPSIS
        Returns Logging module metadata for banner display.
    #>
    [CmdletBinding(PositionalBinding=$false)]
    param()
    $manifestPath = Join-Path $PSScriptRoot 'Logging.psd1'
    [pscustomobject]@{
        Module  = 'Logging'
        Version = (Import-PowerShellDataFile $manifestPath).ModuleVersion
    }
}
