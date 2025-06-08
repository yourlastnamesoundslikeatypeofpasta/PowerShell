---
external help file: SharePointTools-help.xml
Module Name: SharePointTools
online version:
schema: 2.0.0
---

# Find-OrphanedSPFiles

## SYNOPSIS
See DESCRIPTION section.

## SYNTAX

```
Find-OrphanedSPFiles [-SiteUrl] <String> [[-LibraryName] <String>] [[-Days] <Int32>] [[-ClientId] <String>]
 [[-TenantId] <String>] [[-CertPath] <String>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Reports files not modified within a specified number of days.

## EXAMPLES

### Example 1
```powershell
PS C:\> Find-OrphanedSPFiles -? # replace with actual parameters
```

Demonstrates typical usage of Find-OrphanedSPFiles.

## PARAMETERS

### -CertPath
Certificate path used for authentication.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ClientId
Client ID used for authentication.

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

### -Days
Number of days for filtering.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LibraryName
Name of the document library.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SiteUrl
URL of the SharePoint site.

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

### -TenantId
Tenant ID used for authentication.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
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

### None
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
