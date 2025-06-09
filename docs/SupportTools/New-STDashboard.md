---
external help file: SupportTools-help.xml
Module Name: SupportTools
online version:
schema: 2.0.0
---

# New-STDashboard

## SYNOPSIS
Generates an HTML dashboard summarizing logs and telemetry metrics.

## SYNTAX

```
New-STDashboard [[-LogPath] <String>] [[-TelemetryLogPath] <String>] [[-OutputPath] <String>] [[-LogLines] <Int>] [<CommonParameters>]
```

## DESCRIPTION
Reads SupportTools log files and telemetry events then creates a simple HTML page showing the latest log lines and aggregated metrics.

## EXAMPLES

### Example 1
```powershell
PS C:\> New-STDashboard -LogPath log.txt -TelemetryLogPath telemetry.jsonl -LogLines 50
```

Creates a dashboard using custom log paths and shows the last 50 log entries.

## PARAMETERS
### -LogPath
Optional path to the structured log file. Defaults to `$env:ST_LOG_PATH` or `~/SupportToolsLogs/supporttools.log`.

### -TelemetryLogPath
Optional path to the telemetry log file. Defaults to `$env:ST_TELEMETRY_PATH` or `~/SupportToolsTelemetry/telemetry.jsonl`.

### -OutputPath
Optional path for the resulting HTML file. A timestamped file is created in the current directory when omitted.

### -LogLines
Number of log file lines to display. Defaults to `20`.

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

Path to the generated dashboard HTML file.

## NOTES

## RELATED LINKS
