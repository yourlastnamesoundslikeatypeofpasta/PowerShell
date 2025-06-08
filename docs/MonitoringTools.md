# MonitoringTools Module

Provides helper commands for monitoring system health. Import the module using its manifest:

```powershell
Import-Module ./src/MonitoringTools/MonitoringTools.psd1
```

## Available Commands

| Command | Description |
|---------|-------------|
| `Get-DiskSpace` | Show drive size and free space information. |
| `Get-CPUUsage` | Return the current CPU utilisation percentage. |
| `Get-EventLogSummary` | Retrieve recent Application and System event logs. |
| `Get-SystemHealth` | Output an overview of CPU, disk and event log status. |

