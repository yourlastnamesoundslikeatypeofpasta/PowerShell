---
external help file: ServiceDeskTools-help.xml
Module Name: ServiceDeskTools
online version:
schema: 2.0.0
---

# Get-SDTicket

## SYNOPSIS
Retrieves details for a Service Desk incident.

## SYNTAX

```
Get-SDTicket [-Id] <Int32> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Queries the Service Desk API for a single incident and returns the
full incident object.  The command requires the numeric incident ID and
uses the `SD_API_TOKEN` environment variable for authentication.  The
returned object includes common fields such as status, subject,
description, assignee and any custom values defined in your Service
Desk instance.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-SDTicket -Id 123
```

Retrieves incident 123 from the Service Desk.

## PARAMETERS

### -Id
Unique numeric identifier of the incident to retrieve.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: 0
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
