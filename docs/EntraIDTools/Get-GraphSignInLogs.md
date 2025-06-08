---
external help file: EntraIDTools-help.xml
Module Name: EntraIDTools
online version:
schema: 2.0.0
---

# Get-GraphSignInLogs

## SYNOPSIS
Retrieves sign-in events from the Microsoft Graph audit log.

## SYNTAX
```powershell
Get-GraphSignInLogs [-TenantId] <String> [-ClientId] <String> [-ClientSecret <String>] [-UserPrincipalName <String>] [-StartTime <DateTime>] [-EndTime <DateTime>] [<CommonParameters>]
```

## DESCRIPTION
Authenticates with Microsoft Graph and queries the sign-in logs. Results can be filtered by user and date range. Activity is logged and telemetry is recorded.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-GraphSignInLogs -TenantId <tenant-id> -ClientId <app-id>
```
Returns recent sign-in events.

### Example 2
```powershell
PS C:\> Get-GraphSignInLogs -TenantId <tenant-id> -ClientId <app-id> -UserPrincipalName user@contoso.com -StartTime (Get-Date).AddDays(-7) -EndTime (Get-Date)
```
Returns the specified user's sign-ins from the last week.

## PARAMETERS

### -TenantId
GUID identifier for the Entra ID tenant.

### -ClientId
Application (client) ID used for Graph authentication.

### -ClientSecret
Optional client secret for the application.

### -UserPrincipalName
Optional UPN of the user to filter logs.

### -StartTime
Optional beginning of the time range for sign-ins.

### -EndTime
Optional end of the time range for sign-ins.

### CommonParameters
This cmdlet supports the common parameters: `-Debug`, `-ErrorAction`, `-ErrorVariable`, `-InformationAction`, `-InformationVariable`, `-OutVariable`, `-OutBuffer`, `-PipelineVariable`, `-Verbose`, `-WarningAction`, and `-WarningVariable`.

## INPUTS
None.

## OUTPUTS
An array of sign-in log objects.

## NOTES

