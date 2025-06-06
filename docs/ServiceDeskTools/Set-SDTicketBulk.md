---
external help file: ServiceDeskTools-help.xml
Module Name: ServiceDeskTools
online version:
schema: 2.0.0
---

# Set-SDTicketBulk

## SYNOPSIS
Updates multiple incidents with the same field values.

## SYNTAX

```
Set-SDTicketBulk [-Id] <Int32[]> [-Fields] <Hashtable> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Loops through the provided incident IDs and applies the specified fields.

## PARAMETERS

### -Id
Array of incident IDs to update.

### -Fields
Hashtable of fields to modify on each incident.

### -ProgressAction
Specifies how progress is displayed.

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
