---
external help file: ServiceDeskTools-help.xml
Module Name: ServiceDeskTools
online version:
schema: 2.0.0
---

# Link-SDTicketToSPTask

## SYNOPSIS
Associates a Service Desk incident with a SharePoint task.

## SYNTAX

```
Link-SDTicketToSPTask [-TicketId] <Int32> [-TaskUrl] <String> [-FieldName <String>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Stores the provided SharePoint task URL in the specified incident field.

## PARAMETERS

### -TicketId
Service Desk incident ID.

### -TaskUrl
URL of the related SharePoint task.

### -FieldName
Name of the incident field used to store the task link. Defaults to `sharepoint_task_url`.

### -ProgressAction
Specifies how progress is displayed.

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
