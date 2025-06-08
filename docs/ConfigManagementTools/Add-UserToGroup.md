---
external help file: SupportTools-help.xml
Module Name: ConfigManagementTools
online version:
schema: 2.0.0
---

# Add-UserToGroup

## SYNOPSIS
Adds users from a CSV file to a Microsoft 365 group.

## SYNTAX

```
Add-UserToGroup [[-CsvPath] <String>] [[-GroupName] <String>] [[-TranscriptPath] <String>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Wraps the AddUsersToGroup.ps1 script located in the repository's scripts
folder.
Parameters are passed directly through to the script file.

## EXAMPLES

### Example 1
```powershell
PS C:\> Add-UserToGroup -CsvPath './users.csv' -GroupName 'MyGroup'
```

Demonstrates typical usage of Add-UserToGroup.

## PARAMETERS

### -CsvPath
Path to the CSV file containing user principal names.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -GroupName
Name of the Microsoft 365 group to modify.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -TranscriptPath
File path used to capture a transcript of this command's output and actions.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
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
