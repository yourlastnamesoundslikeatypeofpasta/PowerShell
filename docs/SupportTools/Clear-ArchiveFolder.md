---
external help file: SupportTools-help.xml
Module Name: SupportTools
online version:
schema: 2.0.0
---

# Clear-ArchiveFolder

## SYNOPSIS
Removes files and folders from the archived SharePoint directory.

## SYNTAX

```
Clear-ArchiveFolder [[-Arguments] <Object[]>] [[-TranscriptPath] <String>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
This function wraps the CleanupArchive.ps1 script in the scripts folder.
All parameters are forwarded to that script.

## EXAMPLES

### Example 1
```powershell
PS C:\> Clear-ArchiveFolder -SiteUrl 'https://contoso.sharepoint.com/sites/Example' -Libraries 'Shared Documents'
```

Demonstrates typical usage of Clear-ArchiveFolder.

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
{{ Fill TranscriptPath Description }}

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
