---
external help file: SharePointTools-help.xml
Module Name: SharePointTools
online version:
schema: 2.0.0
---

# Invoke-FileVersionCleanup

## SYNOPSIS
Reports files with multiple versions.

## SYNTAX

```
Invoke-FileVersionCleanup [[-SiteName] <String>] [[-SiteUrl] <String>] [[-LibraryName] <String>]
 [[-ClientId] <String>] [[-TenantId] <String>] [[-CertPath] <String>] [[-ReportPath] <String>] [-NoTelemetry]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Generates a CSV of files with more than one version.

## EXAMPLES

### Example 1
```powershell
PS C:\> Invoke-FileVersionCleanup -SiteName 'Example' -SiteUrl 'https://contoso.sharepoint.com/sites/Example'
```

Demonstrates typical usage of Invoke-FileVersionCleanup.

## PARAMETERS

### -SiteName
Friendly name of the site.

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
Position: 3
Default value: Shared Documents
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
Position: 4
Default value: $SharePointToolsSettings.ClientId
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
Position: 5
Default value: $SharePointToolsSettings.TenantId
Accept pipeline input: False
Accept wildcard characters: False
```

### -CertPath
Certificate path used for authentication.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: $SharePointToolsSettings.CertPath
Accept pipeline input: False
Accept wildcard characters: False
```

### -ReportPath
Path to save the generated report.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: ExportedReport.csv
Accept pipeline input: False
Accept wildcard characters: False
```

### -NoTelemetry
Suppress telemetry events for this run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
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
