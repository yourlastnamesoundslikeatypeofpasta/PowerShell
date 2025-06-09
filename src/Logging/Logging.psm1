$repoRoot = Split-Path -Path $PSScriptRoot -Parent | Split-Path -Parent
$coreModule = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath 'STCore/STCore.psd1'
Import-Module $coreModule -ErrorAction SilentlyContinue
$configFile = Join-Path $repoRoot 'config/supporttools.json'
$SupportToolsConfig = Get-STConfig -Path $configFile
if (-not $SupportToolsConfig.ContainsKey('maintenanceMode')) {
    $SupportToolsConfig.maintenanceMode = $false
}
if ($SupportToolsConfig.maintenanceMode) {
    Write-STStatus 'SupportTools is currently in maintenance mode. Exiting.' -Level WARN -Log
    exit 1
}

function Write-STLog {
    [CmdletBinding(DefaultParameterSetName='Message')]
    param(
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'Message')]
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
        [Parameter(Mandatory = $true, ParameterSetName = 'Metric')]
        [ValidateNotNullOrEmpty()]
        [string]$Metric,
        [Parameter(Mandatory = $true, ParameterSetName = 'Metric')]
        [ValidateNotNullOrEmpty()]
        [double]$Value
    )
    if ($PSCmdlet.ParameterSetName -eq 'Metric') {
        if (-not $Metadata) { $Metadata = @{} }
        $Metadata.metric = $Metric
        $Metadata.value  = $Value
        $Message = $Metric
        if (-not $Structured) { $Structured = $true }
    }
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
    Write-STDebug "Logging to $logFile"
    $dir = Split-Path -Path $logFile -Parent
    if (-not (Test-Path $dir)) {
        New-Item -Path $dir -ItemType Directory -Force | Out-Null
    }
    $maxBytes = if ($env:ST_LOG_MAX_BYTES) { [int64]$env:ST_LOG_MAX_BYTES } else { 1048576 }
    if (Test-Path $logFile) {
        $currentBytes = (Get-Item $logFile).Length
        if ($currentBytes -gt $maxBytes) {
            $archive = "$logFile.1"
            try {
                if (Test-Path $archive) { Remove-Item $archive -Force }
                Rename-Item -Path $logFile -NewName $archive -Force
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
        ($entry | ConvertTo-Json -Compress) | Out-File -FilePath $logFile -Append -Encoding utf8
    } else {
        "$timestamp [$module] [$user] [$Level] $Message" | Out-File -FilePath $logFile -Append -Encoding utf8
    }
}

# Writes a structured JSON log entry following a common schema.
function Write-STRichLog {
    [CmdletBinding()]
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
    if ($PSBoundParameters.ContainsKey('User'))     { $entry.user = $User }
    if ($PSBoundParameters.ContainsKey('Duration')) { $entry.duration = $Duration.ToString() }
    if ($PSBoundParameters.ContainsKey('Details'))  { $entry.details  = $Details }

    ($entry | ConvertTo-Json -Depth 5 -Compress) | Out-File -FilePath $logFile -Append -Encoding utf8
}

function Write-STStatus {
    [CmdletBinding()]
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
    [CmdletBinding()]
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
    [CmdletBinding()]
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
    [CmdletBinding()]
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
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$Message = 'Task Complete'
    )
    Write-Host "┌──[ $Message ]──────────────" -ForegroundColor DarkGray
}

Export-ModuleMember -Function 'Write-STLog','Write-STRichLog','Write-STStatus','Show-STPrompt','Write-STDivider','Write-STBlock','Write-STClosing'

function Show-LoggingBanner {
    <#
    .SYNOPSIS
        Returns Logging module metadata for banner display.
    #>
    [CmdletBinding()]
    param()
    $manifestPath = Join-Path $PSScriptRoot 'Logging.psd1'
    [pscustomobject]@{
        Module  = 'Logging'
        Version = (Import-PowerShellDataFile $manifestPath).ModuleVersion
    }
}
