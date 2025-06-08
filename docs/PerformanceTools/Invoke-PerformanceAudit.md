---
external help file: PerformanceTools-help.xml
Module Name: PerformanceTools
online version:
schema: 2.0.0
---

# Invoke-PerformanceAudit

## SYNOPSIS
Performs a system performance audit and optionally creates a Service Desk ticket.

## SYNTAX
```powershell
Invoke-PerformanceAudit [[-CpuThreshold] <int>] [[-MemoryThreshold] <int>] [[-DiskThreshold] <int>] [[-NetworkThreshold] <int>] [-CreateTicket] [-RequesterEmail <string>] [-TranscriptPath <string>] [<CommonParameters>]
```

## DESCRIPTION
Runs the `Invoke-PerformanceAudit.ps1` script located in the module. Parameters are passed directly to the script.

## EXAMPLES
### Example 1
```powershell
PS C:\> Invoke-PerformanceAudit -CreateTicket -RequesterEmail admin@example.com
```
Demonstrates running the audit and creating a ticket when thresholds are exceeded.

## PARAMETERS
### -CpuThreshold
CPU usage percentage that triggers an alert. Default 80.

### -MemoryThreshold
Memory usage percentage that triggers an alert. Default 80.

### -DiskThreshold
Disk utilisation percentage that triggers an alert. Default 80.

### -NetworkThreshold
Network throughput in Mbps that triggers an alert. Default 100.

### -CreateTicket
Create a Service Desk ticket when an alert is generated.

### -RequesterEmail
Requester email address for the ticket.

### -TranscriptPath
Optional transcript log path.

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
