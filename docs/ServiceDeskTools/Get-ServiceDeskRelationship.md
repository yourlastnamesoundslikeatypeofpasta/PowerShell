---
external help file: ServiceDeskTools-help.xml
Module Name: ServiceDeskTools
online version:
schema: 2.0.0
---

# Get-ServiceDeskRelationship

## SYNOPSIS
Retrieves asset relationship records from the Service Desk.

## SYNTAX
```powershell
Get-ServiceDeskRelationship [-AssetId <Int32>] [-Type <String>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Queries the Service Desk API for asset relationships. Use the optional parameters to filter by asset ID and relationship type.

## PARAMETERS
### -AssetId
Asset identifier used to filter relationships.

### -Type
Relationship type filter.

### -ProgressAction
Specifies how progress is displayed.

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS
### PSObject
Relationship objects returned from the Service Desk API.

## NOTES
`SD_ASSET_BASE_URI` can be set to override the default Service Desk base URL for asset requests.

## RELATED LINKS
