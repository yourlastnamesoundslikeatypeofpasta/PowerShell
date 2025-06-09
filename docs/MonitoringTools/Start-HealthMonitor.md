---
external help file: MonitoringTools-help.xml
Module Name: MonitoringTools
online version:
schema: 2.0.0
---

# Start-HealthMonitor

## SYNOPSIS
Periodically log system health metrics.

## SYNTAX
```powershell
Start-HealthMonitor [[-IntervalSeconds] <Int32>] [[-Count] <Int32>] [<CommonParameters>]
```

## DESCRIPTION
`Start-HealthMonitor` calls `Get-SystemHealth` on a recurring interval and writes each result using `Write-STRichLog`. Set `Count` to limit the number of samples; otherwise the command runs until cancelled.

## EXAMPLES
### Example 1
```powershell
PS C:\> Start-HealthMonitor -IntervalSeconds 30 -Count 5
```
Collects five health samples thirty seconds apart.

## PARAMETERS
### -IntervalSeconds
Seconds between health checks. Default is 60. Set `$env:ST_HEALTH_INTERVAL` to
define the interval when the parameter is not provided.
### -Count
Number of samples to capture before exiting. Zero runs indefinitely.

## INPUTS
None. You cannot pipe objects to this command.

## OUTPUTS
None. This command writes structured log entries but does not return data.

## NOTES

## RELATED LINKS
`Get-SystemHealth`
