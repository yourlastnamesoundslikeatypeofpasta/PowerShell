---
external help file: PerformanceTools-help.xml
Module Name: PerformanceTools
online version:
schema: 2.0.0
---

# Invoke-PerformanceAudit

## SYNOPSIS
Collects CPU, memory, disk and network usage and logs the results.

## SYNTAX
```powershell
Invoke-PerformanceAudit [-CpuThreshold <Int>] [-MemoryThreshold <Int>] [-DiskThreshold <Int>] [-NetworkThreshold <Int>] [-CreateTicket] [-RequesterEmail <String>] [-TranscriptPath <String>]
```

## DESCRIPTION
`Invoke-PerformanceAudit` is exported by the `PerformanceTools` module.  The command executes the bundled `Invoke-PerformanceAudit.ps1` script to collect system counters and produce a short performance report. If any metric exceeds the specified threshold values an alert is written to the log. When `-CreateTicket` is supplied a Service Desk ticket is created using `ServiceDeskTools`.

## EXAMPLES
### Example 1
```powershell
PS C:\> Invoke-PerformanceAudit -CreateTicket -RequesterEmail 'admin@example.com'
```
Generates a report and opens a ticket if thresholds are exceeded.

#### Example Output
```text
CpuPercent MemoryPercent DiskPercent NetworkMbps Uptime
--------- ------------ ----------- ----------- ------
42        55           12          1.2          1:23:45
```

## PARAMETERS
### -CpuThreshold
CPU usage percentage that triggers an alert. Default `80`.

### -MemoryThreshold
Memory usage percentage that triggers an alert. Default `80`.

### -DiskThreshold
Disk utilisation percentage that triggers an alert. Default `80`.

### -NetworkThreshold
Network throughput in Mbps that triggers an alert. Default `100`.

### -CreateTicket
Create a Service Desk ticket when an alert is generated.

### -RequesterEmail
Email address used when creating a ticket.

### -TranscriptPath
Optional path for a transcript log.

## INPUTS
None

## OUTPUTS
A custom object with the properties `CpuPercent`, `MemoryPercent`, `DiskPercent`, `NetworkMbps` and `Uptime`. When a ticket is created a `TicketId` property is included.

## NOTES
## RELATED LINKS
