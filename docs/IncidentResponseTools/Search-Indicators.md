---
external help file: SupportTools-help.xml
Module Name: IncidentResponseTools
online version:
schema: 2.0.0
---

# Search-Indicators

## SYNOPSIS
Search event logs, registry and file system for suspicious indicators.

## SYNTAX
```
Search-Indicators -IndicatorList <String> [[-TranscriptPath] <String>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
Calls the `Search-Indicators.ps1` script with the supplied indicator list. The CSV file should contain an `Indicator` column listing values to search for such as IP addresses, domains or file hashes.

## EXAMPLES
### Example 1
```powershell
PS C:\> Search-Indicators -IndicatorList .\indicators.csv
```

Search multiple sources for indicators listed in `indicators.csv`.

## PARAMETERS
### -IndicatorList
Path to a CSV file with an `Indicator` column.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TranscriptPath
File path used to capture a transcript of this command's output and actions.

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

### -ProgressAction
Specifies how progress is displayed.

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
This cmdlet supports the common parameters. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS
## OUTPUTS
### System.Object
Custom objects summarizing match counts for each indicator.

## NOTES
## RELATED LINKS
