---
external help file: SupportTools-help.xml
Module Name: ConfigManagementTools
online version:
schema: 2.0.0
---

# Set-ComputerIPAddress

## SYNOPSIS
Configures the IP address of a local or remote computer.

## SYNTAX

```
Set-ComputerIPAddress [[-Arguments] <Object[]>] [[-TranscriptPath] <String>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Wraps the Set-ComputerIPAddress.ps1 script, forwarding all arguments.

## EXAMPLES

### Example 1
```powershell
PS C:\> Set-ComputerIPAddress -CSVPath './ComputerIPAddress.csv'
```

Demonstrates typical usage of Set-ComputerIPAddress.

## PARAMETERS

### -Arguments
Arguments passed directly to the underlying script.

```yaml
Type: Object[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
