$repoRoot = Split-Path -Path $PSScriptRoot -Parent | Split-Path -Parent
$configFile = Join-Path $repoRoot 'config/supporttools.json'
$SupportToolsConfig = @{ maintenanceMode = $false }
if (Test-Path $configFile) {
    try { $SupportToolsConfig = Get-Content $configFile | ConvertFrom-Json } catch {}
}
if ($SupportToolsConfig.maintenanceMode) {
    Write-Host 'SupportTools is currently in maintenance mode. Exiting.' -ForegroundColor Yellow
    exit 1
}

function Write-STLog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Message,
        [ValidateSet('INFO','WARN','ERROR')]
        [string]$Level = 'INFO',
        [string]$Path,
        [hashtable]$Metadata,
        [switch]$Structured
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
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    if ($Structured) {
        $user = if ($env:USERNAME) { $env:USERNAME } else { $env:USER }
        $script = $MyInvocation.PSCommandPath
        $entry = [ordered]@{
            timestamp = $timestamp
            user      = $user
            script    = $script
            level     = $Level
            message   = $Message
        }
        if ($Metadata) { foreach ($k in $Metadata.Keys) { $entry[$k] = $Metadata[$k] } }
        ($entry | ConvertTo-Json -Compress) | Out-File -FilePath $logFile -Append -Encoding utf8
    } else {
        "$timestamp [$Level] $Message" | Out-File -FilePath $logFile -Append -Encoding utf8
    }
}

# Writes a structured JSON log entry following a common schema.
function Write-STRichLog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Tool,
        [Parameter(Mandatory)][string]$Status,
        [string]$User,
        [timespan]$Duration,
        [string[]]$Details,
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
        [Parameter(Mandatory)]
        [string]$Message,
        [ValidateSet('INFO','SUCCESS','ERROR','WARN','SUB','FINAL','FATAL')]
        [string]$Level = 'INFO',
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
    if ($Log) { Write-STLog -Message "$prefix $Message" }
}

function Show-STPrompt {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Command,
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
        [Parameter(Mandatory)][string]$Title,
        [ValidateSet('light','heavy')][string]$Style = 'light'
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
    param([Parameter(Mandatory)][hashtable]$Data)
    $max = ($Data.Keys | Measure-Object -Property Length -Maximum).Maximum
    foreach ($k in $Data.Keys) {
        $label = ($k + ':').PadRight($max + 1)
        Write-Host "> $label $($Data[$k])" -ForegroundColor Gray
    }
}

function Write-STClosing {
    [CmdletBinding()]
    param([string]$Message = 'Task Complete')
    Write-Host "┌──[ $Message ]──────────────" -ForegroundColor DarkGray
}

Export-ModuleMember -Function 'Write-STLog','Write-STRichLog','Write-STStatus','Show-STPrompt','Write-STDivider','Write-STBlock','Write-STClosing'
