---
external help file: ServiceDeskTools-help.xml
Module Name: ServiceDeskTools
online version:
schema: 2.0.0
---

# Get-ServiceDeskAsset

## SYNOPSIS
Retrieves details for a Service Desk asset.

## SYNTAX
```
Get-ServiceDeskAsset [-Id] <Int32> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Queries the Service Desk API for an asset by numeric identifier. The `SD_API_TOKEN` environment variable must be set. Use `SD_ASSET_BASE_URI` if asset records are hosted at a different base URL than incidents.

## PARAMETERS
### -Id
Identifier of the asset to retrieve.
### -ProgressAction
Specifies how progress is displayed.
### CommonParameters
This cmdlet supports the common parameters. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### PSObject
Raw asset data returned from the API.

## NOTES

## RELATED LINKS

