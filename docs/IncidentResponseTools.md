# IncidentResponseTools Module

Import the module using its manifest:

```powershell
Import-Module ./src/IncidentResponseTools/IncidentResponseTools.psd1
```

All commands log to `%USERPROFILE%\SupportToolsLogs\supporttools.log` unless `$env:ST_LOG_PATH` is set. Use `ST_LOG_STRUCTURED=1` to capture structured JSON entries; see [Logging/RichLogFormat.md](Logging/RichLogFormat.md).

## Available Commands

| Command | Description | Example |
|---------|-------------|---------|
| `Get-CommonSystemInfo` | Return OS, processor, disk and memory details. | `Get-CommonSystemInfo` |
| `Get-FailedLogin` | Retrieve failed login events. | `Get-FailedLogin -ComputerName PC1` |
| `Get-NetworkShare` | List network shares on a computer. | `Get-NetworkShare -ComputerName PC1` |
| `Invoke-IncidentResponse` | Collect forensic data for an incident. | `Invoke-IncidentResponse` |
| `Invoke-RemoteAudit` | Run Get-CommonSystemInfo on remote computers. | `Invoke-RemoteAudit -ComputerName PC1` |
| `Invoke-FullSystemAudit` | Execute common audit scripts and summarize. | `Invoke-FullSystemAudit` |
| `Submit-SystemInfoTicket` | Upload system info and create a ticket. | `Submit-SystemInfoTicket -SiteName IT -RequesterEmail user@contoso.com` |
| `Update-Sysmon` | Update the Sysmon installation. | `Update-Sysmon -SourcePath D:\Tools` |
| `Search-Indicators` | Find indicators in logs, registry and files. | `Search-Indicators -IndicatorList .\indicators.csv` |
