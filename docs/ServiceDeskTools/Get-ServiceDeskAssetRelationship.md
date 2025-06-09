---
external help file: ServiceDeskTools-help.xml
Module Name: ServiceDeskTools
online version:
schema: 2.0.0
---

# Get-ServiceDeskAssetRelationship

## SYNOPSIS
Retrieve relationships between assets.

## SYNTAX
```powershell
Get-ServiceDeskAssetRelationship [-AssetId <Int32>] [-Type <String>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Queries the Service Desk API for asset relationships. You can optionally filter the results by specifying an asset ID and/or relationship type.

## PARAMETERS
### -AssetId
Asset identifier used to filter the results.

### -Type
Relationship type used to filter the results.

### -ProgressAction
Specifies how progress is displayed.

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### PSObject
Relationship objects returned from the Service Desk API.

## NOTES

## RELATED LINKS
