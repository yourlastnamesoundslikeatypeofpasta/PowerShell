---
external help file: ServiceDeskTools-help.xml
Module Name: ServiceDeskTools
online version:
schema: 2.0.0
---

# Get-ServiceDeskStats

## SYNOPSIS
Returns incident counts grouped by status.

## SYNTAX
```powershell
Get-ServiceDeskStats [-StartDate] <DateTime> [-EndDate <DateTime>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Queries the Service Desk API for incidents updated within the specified date range and returns an object where each property is a status name with the number of incidents in that state.

## PARAMETERS
### -StartDate
Only incidents updated after this time are included.

### -EndDate
Only incidents updated before this time are included.

### -ProgressAction
Specifies how progress is displayed.

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### PSCustomObject
Object with properties for each incident status.

## NOTES

## RELATED LINKS
