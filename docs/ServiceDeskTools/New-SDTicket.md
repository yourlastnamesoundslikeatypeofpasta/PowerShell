---
external help file: ServiceDeskTools-help.xml
Module Name: ServiceDeskTools
online version:
schema: 2.0.0
---

# New-SDTicket

## SYNOPSIS
Creates a new Service Desk incident.

## SYNTAX

```
New-SDTicket [-Subject] <String> [-Description] <String> [-RequesterEmail] <String>
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Creates an incident in the Service Desk with the provided subject,
description and requester email address.  The cmdlet sends a POST
request to the Service Desk API using the token stored in the
`SD_API_TOKEN` environment variable.  The response from the API is
returned so you can review the newly created incident number and other
details.

## EXAMPLES

### Example 1
```powershell
PS C:\> New-SDTicket -Subject "Printer issue" -Description "Printer won't print" -RequesterEmail "jane.doe@example.com"
```

Creates a new incident describing a printer problem.

## PARAMETERS

### -Subject
Short title summarizing the issue being reported.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Description
Detailed explanation of the problem to be logged.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RequesterEmail
Email address of the user opening the incident.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProgressAction
Specifies how progress is displayed.

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
