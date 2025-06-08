---
external help file: ServiceDeskTools-help.xml
Module Name: ServiceDeskTools
online version:
schema: 2.0.0
---

# Get-ServiceDeskStats

Retrieves incident counts grouped by state for a date range.

## SYNTAX

```
Get-ServiceDeskStats [-From] <DateTime> [-To] <DateTime> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Queries the Service Desk API for incidents created within the specified time window and returns a summary object with counts per state and a total.

## PARAMETERS

### -From
Start of the date range to query.

### -To
End of the date range to query.

### -ProgressAction
Specifies how progress is displayed.

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### PSCustomObject
Object with Total count and one property for each incident state.

## NOTES

## RELATED LINKS
