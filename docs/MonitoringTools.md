# MonitoringTools Module

Provides commands for collecting system metrics and health information.
Import the module using its manifest:

```powershell
Import-Module ./src/MonitoringTools/MonitoringTools.psd1
```

Log entries are written to `%USERPROFILE%\SupportToolsLogs\supporttools.log` by default. Specify `$env:ST_LOG_PATH` for a custom path. Set `ST_LOG_STRUCTURED=1` to record JSON formatted events (see [Logging/RichLogFormat.md](Logging/RichLogFormat.md)).

## Available Commands

| Command | Description | Example |
|---------|-------------|---------|
| `Get-CPUUsage` | Returns the current CPU utilisation. | `Get-CPUUsage` |
| `Get-DiskSpaceInfo` | Lists disk free space. | `Get-DiskSpaceInfo` |
| `Get-EventLogSummary` | Counts recent error and warning events. | `Get-EventLogSummary -LogName System` |
| `Get-SystemHealth` | Summarises CPU, disk and event log data. | `Get-SystemHealth` |
| `Start-HealthMonitor` | Periodically log system health metrics. | `Start-HealthMonitor -IntervalSeconds 60` |

See [MonitoringTools/Start-HealthMonitor.md](MonitoringTools/Start-HealthMonitor.md) for full command help.
