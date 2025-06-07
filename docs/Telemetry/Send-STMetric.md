---
external help file: Telemetry-help.xml
Module Name: Telemetry
online version:
schema: 2.0.0
---

# Send-STMetric

## SYNOPSIS
Records a structured metric entry in the telemetry log.

## SYNTAX
```powershell
Send-STMetric [-MetricName] <string> [-Category] <string> [-Value] <double> [[-Details] <hashtable>] [<CommonParameters>]
```

## DESCRIPTION
Writes a timestamped metric object to the telemetry log. Each entry includes a unique operation ID so related metrics and events can be correlated.

## PARAMETERS
### -MetricName
Name of the metric to record.
### -Category
Logical category for the metric such as `Audit`, `Deployment` or `Remediation`.
### -Value
Numeric value for the metric.
### -Details
Optional key/value data to include with the metric.

## OUTPUTS
None. Metrics are appended to the telemetry log.
