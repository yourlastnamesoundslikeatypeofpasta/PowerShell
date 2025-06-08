# MonitoringTools Module

Provides lightweight health monitoring commands. Import the module using its manifest:

```powershell
Import-Module ./src/MonitoringTools/MonitoringTools.psd1
```

Each command records a structured log entry via `Write-STRichLog` including the computer name and timestamp.

## Available Commands

| Command | Description |
|---------|-------------|
| `Get-CPUUsage` | Return the current average CPU utilisation. |
| `Get-DiskSpaceInfo` | List disk sizes and free space. |
| `Get-EventLogSummary` | Summarise Error and Warning events from the last hours. |
| `Get-SystemHealth` | Combine CPU, disk and event log information. |
