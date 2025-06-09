---
external help file: ServiceDeskTools-help.xml
Module Name: ServiceDeskTools
online version:
schema: 2.0.0
---

# Get-SDUser

## SYNOPSIS
Retrieves user details from the Service Desk.

## SYNTAX
```
Get-SDUser [-Id] <Int32> [-ProgressAction <ActionPreference>] [<CommonParameters>]
Get-SDUser [-Email] <String> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Queries the Service Desk `/users` API for information about a single user. You can
provide either a numeric id or an email address to locate the user record.

## PARAMETERS
### -Id
Identifier of the user to retrieve.

### -Email
Email address used to look up the user.

### -ProgressAction
Specifies how progress is displayed.

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable,
-Verbose, -WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS
### PSObject
User object returned from the Service Desk API.

## NOTES

## RELATED LINKS
