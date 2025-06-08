---
external help file: PerformanceTools-help.xml
Module Name: PerformanceTools
online version:
schema: 2.0.0
---

# Invoke-PerformanceAudit

## SYNOPSIS
Runs the Invoke-PerformanceAudit.ps1 script to gather system metrics.

## SYNTAX
```powershell
Invoke-PerformanceAudit [-CpuThreshold <Int>] [-MemoryThreshold <Int>] [-DiskThreshold <Int>] [-NetworkThreshold <Int>] [-CreateTicket] [-RequesterEmail <String>] [-TranscriptPath <String>] [<CommonParameters>]
```

## DESCRIPTION
Wrapper for the script of the same name contained in this module. Parameters are passed directly to the script file.

## EXAMPLES
### Example 1
```powershell
PS C:\> Invoke-PerformanceAudit -CreateTicket -RequesterEmail 'admin@example.com'
```

Runs the audit and creates a ticket if thresholds are exceeded.

## PARAMETERS
### -CpuThreshold
CPU usage percentage that triggers an alert.

### -MemoryThreshold
Memory usage percentage that triggers an alert.

### -DiskThreshold
Disk utilisation percentage that triggers an alert.

### -NetworkThreshold
Network throughput in Mbps that triggers an alert.

### -CreateTicket
Create a Service Desk ticket when an alert is generated.

### -RequesterEmail
Requester email address for the ticket.

### -TranscriptPath
Optional transcript log path.

### CommonParameters
This cmdlet supports the common parameters. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS
## OUTPUTS
## NOTES
## RELATED LINKS
