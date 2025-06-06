---
external help file: SupportTools-help.xml
Module Name: SupportTools
online version:
schema: 2.0.0
---

# Restore-ArchiveFolder

## SYNOPSIS
Restores files and folders previously removed by Clear-ArchiveFolder.

## SYNTAX
```
Restore-ArchiveFolder [[-Arguments] <Object[]>] [[-TranscriptPath] <String>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
This function wraps the RollbackArchive.ps1 script in the scripts folder.
All parameters are forwarded to that script.

## EXAMPLES

### Example 1
```powershell
PS C:\> Restore-ArchiveFolder -SiteUrl 'https://contoso.sharepoint.com/sites/Example' -SnapshotPath preDeleteLog.json
```
Demonstrates typical usage of Restore-ArchiveFolder.

## PARAMETERS

### -Arguments
Arguments passed directly to the underlying script.
```
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
```
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
```
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
