---
external help file: ServiceDeskTools-help.xml
Module Name: ServiceDeskTools
online version:
schema: 2.0.0
---

# Set-SDTicket

## SYNOPSIS
Updates an existing Service Desk incident.

## SYNTAX

```
Set-SDTicket [-Id] <Int32> [-Fields] <Hashtable> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Updates an existing Service Desk incident by sending a PUT request to
the API.  Provide the incident ID along with a hashtable of fields and
values you wish to modify.  The command uses the authentication token
from `SD_API_TOKEN` and returns the updated incident object from the
Service Desk.

## EXAMPLES

### Example 1
```powershell
PS C:\> Set-SDTicket -Id 123 -Fields @{ status = 'Resolved'; assignee = 'jane.doe@example.com' }
```

Marks incident 123 as resolved and assigns it to Jane Doe.

## PARAMETERS

### -Id
Unique identifier of the incident to modify.

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

### -Fields
Hashtable containing incident field names and the values to apply.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
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
