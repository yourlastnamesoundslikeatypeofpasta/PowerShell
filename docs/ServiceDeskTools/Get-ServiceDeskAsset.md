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
Queries the Service Desk API for an asset by numeric identifier.
The command requires the asset ID and uses the `SD_API_TOKEN`
environment variable for authentication.

## PARAMETERS

### -Id
Unique numeric identifier of the asset to retrieve.

### -ProgressAction
Specifies how progress is displayed.

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### PSObject
The asset returned by the Service Desk API.

## NOTES

## RELATED LINKS
