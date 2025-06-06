---
external help file: SharePointTools-help.xml
Module Name: SharePointTools
online version:
schema: 2.0.0
---

# Select-SPToolsFolder

## SYNOPSIS
Interactively choose a folder from a SharePoint document library.

## SYNTAX
```
Select-SPToolsFolder [[-SiteName] <String>] [[-SiteUrl] <String>] [[-LibraryName] <String>] [[-Filter] <String>] [[-ClientId] <String>] [[-TenantId] <String>] [[-CertPath] <String>] [<CommonParameters>]
```

## DESCRIPTION
Recursively lists folders in the target library and prompts for a selection. Provide a filter string to narrow the results.

## EXAMPLES
### Example 1
```powershell
PS C:\> Select-SPToolsFolder -SiteName HR
```
Choose a folder from the HR site's Shared Documents library.

## PARAMETERS
### -SiteName
Friendly name of the site.

### -SiteUrl
Full URL of the site.

### -LibraryName
Document library to browse. Defaults to `Shared Documents`.

### -Filter
Optional string used to filter folder paths.

### -ClientId
### -TenantId
### -CertPath

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
