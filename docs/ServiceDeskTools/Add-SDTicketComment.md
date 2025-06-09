---
external help file: ServiceDeskTools-help.xml
Module Name: ServiceDeskTools
online version:
schema: 2.0.0
---

# Add-SDTicketComment

## SYNOPSIS
Adds a comment to a Service Desk incident.

## SYNTAX

```
Add-SDTicketComment [-Id] <Int32> [-Comment] <String> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Sends a POST request to the Service Desk API to append a comment to an existing incident.

## PARAMETERS

### -Id
Incident ID to update.

### -Comment
Text body of the comment.

### -ProgressAction
Specifies how progress is displayed.

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
