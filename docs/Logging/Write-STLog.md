---
external help file: Logging-help.xml
Module Name: Logging
online version:
schema: 2.0.0
---

# Write-STLog

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

```
Write-STLog [-Message] <String> [[-Level] <String>] [[-Path] <String>] [-ProgressAction <ActionPreference>]
[[-Metadata] <Hashtable>] [-Structured]
[[-Metric] <String>] [[-Value] <Double>]
[<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

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
{{ Fill Level Description }}

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
{{ Fill Message Description }}

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
Outputs the log entry as a JSON object.
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
Set the `ST_LOG_STRUCTURED` environment variable to `1` to enable structured output by default.

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

### -ProgressAction
{{ Fill ProgressAction Description }}

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

## RELATED LINKS
