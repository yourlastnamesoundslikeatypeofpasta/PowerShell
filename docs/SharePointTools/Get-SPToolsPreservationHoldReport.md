---
external help file: SharePointTools-help.xml
Module Name: SharePointTools
online version:
schema: 2.0.0
---

# Get-SPToolsPreservationHoldReport

## SYNOPSIS
Reports the size of the Preservation Hold Library.

## SYNTAX

```
Get-SPToolsPreservationHoldReport [-SiteName] <String> [[-SiteUrl] <String>] [[-ClientId] <String>]
 [[-TenantId] <String>] [[-CertPath] <String>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Description forthcoming for Get-SPToolsPreservationHoldReport.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-SPToolsPreservationHoldReport -SiteName HR
```

Demonstrates typical usage of Get-SPToolsPreservationHoldReport.

## PARAMETERS

### -SiteName
Friendly name of the site.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
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

### -ClientId
Client ID used for authentication.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
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
Position: 4
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
Position: 5
Default value: $SharePointToolsSettings.CertPath
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
Uses PnP.PowerShell commands.
See https://pnp.github.io/powershell/ for details.

## RELATED LINKS
