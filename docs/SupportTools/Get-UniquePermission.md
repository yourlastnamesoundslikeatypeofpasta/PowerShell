---
external help file: SupportTools-help.xml
Module Name: SupportTools
online version:
schema: 2.0.0
---

# Get-UniquePermission

## SYNOPSIS
Returns items with unique permissions in a SharePoint site.

## SYNTAX

```
Get-UniquePermission [[-Arguments] <Object[]>] [[-TranscriptPath] <String>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Calls the Get-UniquePermissions.ps1 script contained in the scripts
directory and outputs its results.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-UniquePermission -SiteUrl 'https://contoso.sharepoint.com/sites/Example'
```

Demonstrates typical usage of Get-UniquePermission.

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

An object containing the wrapped script output.

```
Script : Get-UniquePermissions.ps1
Result : <object[]>
```
## NOTES

## RELATED LINKS
