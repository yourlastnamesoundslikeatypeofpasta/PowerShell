function Send-SPToolsTelemetryEvent {
    [CmdletBinding()]
    param(
        [string]$Command,
        [string]$Result,
        [timespan]$Duration
    )
    try {
        Write-STTelemetryEvent -ScriptName $Command -Result $Result -Duration $Duration -Category "SharePointTools"
    } catch {}
}


