---
external help file: SupportTools-help.xml
Module Name: SupportTools
online version:
schema: 2.0.0
---

# Submit-SystemInfoTicket

## SYNOPSIS
Collects system information, uploads it to SharePoint and creates a Service Desk ticket.

## SYNTAX

```
Submit-SystemInfoTicket [-SiteName] <String> [-RequesterEmail] <String> [[-Subject] <String>] [[-Description] <String>] [[-LibraryName] <String>] [[-FolderPath] <String>] [[-TranscriptPath] <String>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Wraps the Submit-SystemInfoTicket.ps1 script. The command gathers common system information, uploads the JSON report to the specified SharePoint site and then opens a Service Desk ticket referencing the uploaded file.

## EXAMPLES

### Example 1
```powershell
PS C:\> Submit-SystemInfoTicket -SiteName IT -RequesterEmail "jane.doe@example.com"
```
Collects system info, uploads the report to the IT site and creates a ticket for jane.doe@example.com.

## PARAMETERS

### -SiteName
Friendly name of the SharePoint site configured with Configure-SharePointTools.

### -RequesterEmail
Email address of the ticket requester.

### -Subject
Ticket subject. Defaults to "System info from <computername>".

### -Description
Ticket description. Defaults to a short message referencing the uploaded report.

### -LibraryName
Document library to upload the report. Defaults to "Shared Documents".

### -FolderPath
Optional folder path within the library.

### -TranscriptPath
Optional transcript output path.

### -ProgressAction
Specifies how progress is displayed.

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
