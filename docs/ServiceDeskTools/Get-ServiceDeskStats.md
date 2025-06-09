---
external help file: ServiceDeskTools-help.xml
Module Name: ServiceDeskTools
online version:
schema: 2.0.0
---

# Get-ServiceDeskStats

## SYNOPSIS
Retrieves incident counts grouped by status.

## SYNTAX
```
Get-ServiceDeskStats [-StartDate] <DateTime> [-EndDate] <DateTime> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Queries `/incidents.json` using the provided date range and groups the returned incidents by their `state` value. The result is an object with properties for each status and the corresponding count.

## EXAMPLES
### Example 1
```powershell
Get-ServiceDeskStats -StartDate '2024-01-01' -EndDate '2024-01-31'
```
Retrieves counts for incidents created in January 2024.

## PARAMETERS
### -StartDate
Beginning of the date range to query.

### -EndDate
End of the date range to query.

### -ProgressAction
Specifies how progress is displayed.

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### PSObject
Object containing status names and counts.

## NOTES

## RELATED LINKS
