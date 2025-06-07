---
external help file: SharePointTools-help.xml
Module Name: SharePointTools
online version:
schema: 2.0.0
---

# Get-SPToolsFileReport

## SYNOPSIS
Return metadata for all files in a document library.

## SYNTAX

```
Get-SPToolsFileReport [-SiteName] <String> [[-SiteUrl] <String>] [[-LibraryName] <String>] [[-ClientId] <String>] [[-TenantId] <String>] [[-CertPath] <String>] [[-ReportPath] <String>] [[-PageSize] <Int32>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Collects detailed information about each file in the specified library. When `-ReportPath` is supplied the data is written to a CSV file.

## EXAMPLES

### Example 1
```powershell
Get-SPToolsFileReport -SiteName HR -ReportPath files.csv
```

## PARAMETERS

### -SiteName
Friendly name of the site.

### -SiteUrl
URL of the SharePoint site if not stored in settings.

### -LibraryName
Name of the document library. Defaults to `Documents`.

### -ClientId
Client ID used for authentication.

### -TenantId
Tenant ID used for authentication.

### -CertPath
Certificate path used for authentication.

### -ReportPath
Optional path for the exported CSV report.

### -PageSize
Number of items retrieved per request. Defaults to 5000.

### CommonParameters
This cmdlet supports the common parameters.

## INPUTS
### None

## OUTPUTS
System.Object

## NOTES

## RELATED LINKS

