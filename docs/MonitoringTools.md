# MonitoringTools Module

Provides commands for collecting system metrics and health information.
Import the module using its manifest:

```powershell
Import-Module ./src/MonitoringTools/MonitoringTools.psd1
```

## Available Commands

| Command | Description | Example |
|---------|-------------|---------|
| `Get-CPUUsage` | Returns the current CPU utilisation and writes a structured log. | `Get-CPUUsage` |
| `Get-DiskSpaceInfo` | Lists disk free space and logs the details. | `Get-DiskSpaceInfo` |
| `Get-EventLogSummary` | Counts recent error and warning events and logs a summary. | `Get-EventLogSummary -LogName System` |
| `Get-SystemHealth` | Summarises CPU, disk and event log data and records the snapshot. | `Get-SystemHealth` |
| `Start-HealthMonitor` | Periodically log system health metrics. | `Start-HealthMonitor -IntervalSeconds 60` |

See [MonitoringTools/Start-HealthMonitor.md](MonitoringTools/Start-HealthMonitor.md) for full command help.
