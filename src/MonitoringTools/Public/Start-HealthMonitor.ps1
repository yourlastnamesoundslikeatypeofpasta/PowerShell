function Start-HealthMonitor {
    <#
    .SYNOPSIS
        Periodically logs system health metrics.
    .DESCRIPTION
        Calls Get-SystemHealth in a loop. Each result is written to the structured
        log using Write-STRichLog. Specify Count to limit the number of samples;
        otherwise the command runs until cancelled.
    .PARAMETER IntervalSeconds
        Seconds between health checks. Defaults to 60.
    .PARAMETER Count
        Number of samples to collect before exiting. 0 runs indefinitely.
    .PARAMETER LogPath
        Optional path for the rich log file. Defaults to $env:ST_LOG_PATH or
        ~/SupportToolsLogs/supporttools.log.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [int]$IntervalSeconds = 60,
        [int]$Count = 0,
        [string]$LogPath
    )

    if (-not $PSBoundParameters.ContainsKey('IntervalSeconds')) {
        if ($env:ST_HEALTH_INTERVAL) { $IntervalSeconds = [int]$env:ST_HEALTH_INTERVAL }
    }

    if (-not $PSCmdlet.ShouldProcess('system health monitoring')) { return }

    try {
        $collected = 0
        while (-not $script:StopHealthMonitor -and ($Count -eq 0 -or $collected -lt $Count)) {
            $start = Get-Date
            $health = Get-SystemHealth
            $json = $health | ConvertTo-Json -Compress
            if ($PSBoundParameters.ContainsKey('LogPath')) {
                Write-STRichLog -Tool 'HealthMonitor' -Status 'sample' -Details $json -Path $LogPath
            }
            else {
                Write-STRichLog -Tool 'HealthMonitor' -Status 'sample' -Details $json
            }

            $collected++

            $elapsed = (Get-Date) - $start
            $sleep = $IntervalSeconds - [int][math]::Floor($elapsed.TotalSeconds)
            if ($sleep -gt 0) { Start-Sleep -Seconds $sleep }
        }
    }
    catch {
        return New-STErrorRecord -Message $_.Exception.Message -Exception $_.Exception
    }
}
