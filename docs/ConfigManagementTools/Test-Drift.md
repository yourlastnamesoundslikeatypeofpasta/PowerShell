---
external help file: SupportTools-help.xml
Module Name: ConfigManagementTools
online version:
schema: 2.0.0
---

# Test-Drift

## SYNOPSIS
Checks the system state against a baseline configuration file.

## SYNTAX

```
Test-Drift [-BaselinePath] <String> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Reads a JSON baseline containing expected timezone, hostname and service statuses.
Outputs any detected deviations from the current system.

## EXAMPLES

### Example 1
```powershell
PS C:\> Test-Drift -BaselinePath './baseline.json'
```

Demonstrates typical usage of Test-Drift.

## PARAMETERS

### -BaselinePath
Path to the baseline JSON file.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
