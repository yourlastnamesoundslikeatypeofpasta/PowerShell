---
external help file: ServiceDeskTools-help.xml
Module Name: ServiceDeskTools
online version:
schema: 2.0.0
---

# Search-SDTicket

## SYNOPSIS
Searches Service Desk incidents by keyword.

## SYNTAX

```
Search-SDTicket [-Query] <String> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Returns incidents that match the provided search text.

## PARAMETERS

### -Query
Text used to search incident subjects and descriptions.

### -ProgressAction
Specifies how progress is displayed.

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### TicketObject[]
Array of matching incidents.

## NOTES

## RELATED LINKS
