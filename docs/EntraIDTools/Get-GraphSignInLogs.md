---
external help file: EntraIDTools-help.xml
Module Name: EntraIDTools
online version:
schema: 2.0.0
---

# Get-GraphSignInLogs

## SYNOPSIS
Retrieves user sign-in events from the Microsoft Graph audit logs.

## SYNTAX
```powershell
Get-GraphSignInLogs [-UserPrincipalName <String>] [-StartTime <DateTime>] [-EndTime <DateTime>] [-TenantId] <String> [-ClientId] <String> [-ClientSecret <String>] [<CommonParameters>]
```

## DESCRIPTION
Authenticates with Microsoft Graph and queries the auditLogs/signIns endpoint.
Results can be filtered by user principal name and a start and end time range.
Activity is logged and telemetry is recorded.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-GraphSignInLogs -UserPrincipalName user@contoso.com -StartTime (Get-Date).AddDays(-1) -TenantId <tenant-id> -ClientId <app-id>
```
Retrieves sign-in events for the specified user from the last day.

## PARAMETERS

### -UserPrincipalName
UPN of the account to filter the logs.

### -StartTime
Start of the time range to query.

### -EndTime
End of the time range to query.

### -TenantId
GUID identifier for the Entra ID tenant containing the logs.

### -ClientId
Application (client) ID used for Microsoft Graph authentication.

### -ClientSecret
Optional client secret for app-only authentication.

### CommonParameters
This cmdlet supports the common parameters: `-Debug`, `-ErrorAction`, `-ErrorVariable`, `-InformationAction`, `-InformationVariable`, `-OutVariable`, `-OutBuffer`, `-PipelineVariable`, `-Verbose`, `-WarningAction`, and `-WarningVariable`.

## INPUTS
None.

## OUTPUTS
An array of sign-in log objects.

## NOTES
