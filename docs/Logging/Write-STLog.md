---
external help file: Logging-help.xml
Module Name: Logging
online version:
schema: 2.0.0
---

# Write-STLog

## SYNOPSIS
Writes a message or metric to the SupportTools log.

## SYNTAX

```
Write-STLog [-Message] <String> [[-Level] <String>] [[-Path] <String>] [-ProgressAction <ActionPreference>]
[[-Metadata] <Hashtable>] [-Structured]
[[-Metric] <String>] [[-Value] <Double>]
[<CommonParameters>]
```

## DESCRIPTION
Records log messages in a consistent format. Logs are written to `%USERPROFILE%\SupportToolsLogs\supporttools.log` or `$env:ST_LOG_PATH` if set.
Set `ST_LOG_STRUCTURED=1` or use `-Structured` to output JSON lines. The structure is described in [RichLogFormat.md](./RichLogFormat.md).

## LOG LEVELS
The `-Level` parameter accepts the following values:

- **INFO** - informational messages
- **WARN** - warnings that may require attention
- **ERROR** - errors that prevented an action

`Write-STStatus` respects the `$env:ST_LOG_LEVEL` variable using the same values to filter console output.

## EXAMPLES

### Example 1
```powershell
PS C:\> $sw = [System.Diagnostics.Stopwatch]::StartNew()
PS C:\> # ... task runs ...
PS C:\> $sw.Stop()
PS C:\> Write-STLog -Metric 'Duration' -Value $sw.Elapsed.TotalSeconds
```
Records how long the task took in seconds using a structured log entry.

## PARAMETERS

### -Level
Specifies the log level such as INFO, WARN, or ERROR.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: INFO, WARN, ERROR

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Message
The content of the log entry to record.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path
Custom path to the log file. Overrides the default location and the `ST_LOG_PATH`
environment variable.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Metadata
Additional key/value pairs to add to structured log entries.
```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Structured
Outputs the log entry as a JSON object. Set the `ST_LOG_STRUCTURED` environment variable to `1` to enable structured output by default.
```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Metric
Name of a metric to record. Automatically enables structured output.
```yaml
Type: String
Parameter Sets: Metric
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Value
Numeric value associated with `-Metric`.
```yaml
Type: Double
Parameter Sets: Metric
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MaxSizeMB
Maximum size in megabytes before the log rotates.
```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 1
Accept pipeline input: False
Accept wildcard characters: False
```

### -MaxFiles
Number of rotated log files to keep.
```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 1
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProgressAction
Specifies how this cmdlet responds to progress updates.

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None
## OUTPUTS

### System.Object
## NOTES

Logs rotate automatically when their size exceeds `-MaxSizeMB` (default 1 MB).
Older files are preserved up to `-MaxFiles` with incrementing numeric
extensions.

## RELATED LINKS
[RichLogFormat.md](./RichLogFormat.md)
