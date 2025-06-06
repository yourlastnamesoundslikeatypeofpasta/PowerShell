function Write-STLog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Message,
        [ValidateSet('INFO','WARN','ERROR')]
        [string]$Level = 'INFO'
    )
    $logDir = Join-Path $env:USERPROFILE 'SupportToolsLogs'
    if (-not (Test-Path $logDir)) {
        New-Item -Path $logDir -ItemType Directory -Force | Out-Null
    }
    $logFile = Join-Path $logDir 'supporttools.log'
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    "$timestamp [$Level] $Message" | Out-File -FilePath $logFile -Append -Encoding utf8
}

Export-ModuleMember -Function 'Write-STLog'
