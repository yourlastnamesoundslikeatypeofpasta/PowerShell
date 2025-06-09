---
external help file: ServiceDeskTools-help.xml
Module Name: ServiceDeskTools
online version:
schema: 2.0.0
---

# Get-ServiceDeskStats

## SYNOPSIS
Returns counts of Service Desk incidents grouped by status.

## SYNTAX
```powershell
Get-ServiceDeskStats [-StartDate] <DateTime> [-EndDate] <DateTime> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Queries the Service Desk API for incidents created between the specified start and end dates. The resulting incidents are grouped by their status field and returned as an object where each property is a status name with the count of incidents.

## PARAMETERS
### -StartDate
Beginning of the date range (inclusive).

### -EndDate
End of the date range (inclusive).

### -ProgressAction
Specifies how progress is displayed.

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### PSObject
An object with properties representing incident status names and their counts.

## NOTES

## RELATED LINKS
