
function Write-STTelemetryEvent {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$ScriptName,
        [Parameter(Mandatory)][string]$Result,
        [Parameter(Mandatory)][timespan]$Duration
    )
    if ($env:ST_ENABLE_TELEMETRY -ne '1') { return }

    $userProfile = if ($env:USERPROFILE) { $env:USERPROFILE } else { $env:HOME }
    if ($env:ST_TELEMETRY_PATH) {
        $logFile = $env:ST_TELEMETRY_PATH
    } else {
        $dir = Join-Path $userProfile 'SupportToolsTelemetry'
        $logFile = Join-Path $dir 'telemetry.jsonl'
    }
    $dir = Split-Path -Path $logFile -Parent
    if (-not (Test-Path $dir)) {
        New-Item -Path $dir -ItemType Directory -Force | Out-Null
    }
    $event = [pscustomobject]@{
        Timestamp = (Get-Date).ToString('o')
        Script    = $ScriptName
        Result    = $Result
        Duration  = [math]::Round($Duration.TotalSeconds, 2)
    } | ConvertTo-Json -Compress

    $event | Out-File -FilePath $logFile -Encoding utf8 -Append
}

Export-ModuleMember -Function 'Write-STTelemetryEvent'
