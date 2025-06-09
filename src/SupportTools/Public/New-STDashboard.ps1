function New-STDashboard {
    <#
    .SYNOPSIS
        Generates an HTML dashboard summarizing logs and telemetry metrics.
    .DESCRIPTION
        Reads SupportTools log files and telemetry events then creates a simple
        HTML page showing the latest log lines and aggregated metrics.
    .PARAMETER LogPath
        Optional path to the structured log file. Defaults to $env:ST_LOG_PATH or
        ~/SupportToolsLogs/supporttools.log.
    .PARAMETER TelemetryLogPath
        Optional path to the telemetry log file. Defaults to $env:ST_TELEMETRY_PATH
        or ~/SupportToolsTelemetry/telemetry.jsonl.
    .PARAMETER OutputPath
        Optional path for the resulting HTML file. A timestamped file is created
        in the current directory when omitted.
    .PARAMETER LogLines
        Number of log file lines to display. Defaults to 20.
    .EXAMPLE
        New-STDashboard -LogPath log.txt -TelemetryLogPath telemetry.jsonl
    #>
    [CmdletBinding()]
    param(
        [string]$LogPath,
        [string]$TelemetryLogPath,
        [string]$OutputPath,
        [int]$LogLines = 20
    )
    try {
        if (-not $OutputPath) {
            $OutputPath = Join-Path (Get-Location) "STDashboard_$((Get-Date).ToString('yyyyMMdd_HHmmss')).html"
        }
        if (-not $LogPath) {
            if ($env:ST_LOG_PATH) { $LogPath = $env:ST_LOG_PATH }
            else { $LogPath = Join-Path $HOME 'SupportToolsLogs/supporttools.log' }
        }
        if (-not $TelemetryLogPath) {
            if ($env:ST_TELEMETRY_PATH) { $TelemetryLogPath = $env:ST_TELEMETRY_PATH }
            else { $TelemetryLogPath = Join-Path $HOME 'SupportToolsTelemetry/telemetry.jsonl' }
        }

        $logLines = if (Test-Path $LogPath) { Get-Content $LogPath -Tail $LogLines } else { @() }
        $metrics  = if (Test-Path $TelemetryLogPath) { Get-STTelemetryMetrics -LogPath $TelemetryLogPath } else { @() }

        # Build HTML using a growable list to avoid += inside loops
        $html = [System.Collections.Generic.List[string]]::new()
        $html.Add('<html><head><title>Support Tools Dashboard</title></head><body>')
        $html.Add('<h1>Support Tools Dashboard</h1>')
        $html.Add('<h2>Recent Log Entries</h2>')
        if ($logLines.Count -gt 0) {
            $html.Add('<pre>')
            $html.Add(($logLines | ForEach-Object { $_ -replace '<','&lt;' -replace '>','&gt;' }) -join "`n")
            $html.Add('</pre>')
        } else {
            $html.Add('<p>No log entries found.</p>')
        }
        $html.Add('<h2>Telemetry Metrics</h2>')
        if ($metrics.Count -gt 0) {
            $html.Add('<table border="1"><tr><th>Script</th><th>Executions</th><th>Successes</th><th>Failures</th><th>AverageSeconds</th><th>LastRun</th></tr>')
            foreach ($m in $metrics) {
                $html.Add("<tr><td>$($m.Script)</td><td>$($m.Executions)</td><td>$($m.Successes)</td><td>$($m.Failures)</td><td>$($m.AverageSeconds)</td><td>$($m.LastRun)</td></tr>")
            }
            $html.Add('</table>')
        } else {
            $html.Add('<p>No telemetry metrics found.</p>')
        }
        $html.Add('</body></html>')

        $html -join "`n" | Out-File -FilePath $OutputPath -Encoding utf8
        Write-STStatus "Dashboard saved to $OutputPath" -Level SUCCESS
        return $OutputPath
    } catch {
        return New-STErrorRecord -Message $_.Exception.Message -Exception $_.Exception
    }
}
