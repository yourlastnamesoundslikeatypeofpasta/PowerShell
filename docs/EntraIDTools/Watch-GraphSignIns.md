---
external help file: EntraIDTools-help.xml
Module Name: EntraIDTools
online version:
schema: 2.0.0
---

# Watch-GraphSignIns

## SYNOPSIS
Monitors sign-in logs for risky events and creates a Service Desk ticket.

## SYNTAX
```powershell
Watch-GraphSignIns [-Threshold <String>] -TenantId <String> -ClientId <String> [-ClientSecret <String>] -RequesterEmail <String> [-ChaosMode] [<CommonParameters>]
```

## DESCRIPTION
Retrieves recent sign-in logs using `Get-GraphSignInLogs`. When any entry has a risk level at or above `-Threshold`, `New-SDTicket` is called to open an incident. Logging, telemetry and optional chaos mode are used.

## EXAMPLES
### Example 1
```powershell
PS C:\> Watch-GraphSignIns -Threshold Medium -TenantId <tenant-id> -ClientId <app-id> -RequesterEmail 'secops@contoso.com'
```
Checks for sign-ins with Medium or High risk and creates a Service Desk ticket if any are found.

## PARAMETERS
### -Threshold
Minimum risk level that triggers ticket creation. Values: Low, Medium, High. Default is High.

### -TenantId
GUID identifier for the Entra ID tenant containing the logs.

### -ClientId
Application (client) ID used for Microsoft Graph authentication.

### -ClientSecret
Optional client secret for app-only authentication.

### -RequesterEmail
Email address of the Service Desk ticket requester.

### -ChaosMode
Enable API Chaos Mode when creating the ticket.

### CommonParameters
This cmdlet supports the common parameters: `-Debug`, `-ErrorAction`, `-ErrorVariable`, `-InformationAction`, `-InformationVariable`, `-OutVariable`, `-OutBuffer`, `-PipelineVariable`, `-Verbose`, `-WarningAction`, and `-WarningVariable`.

## INPUTS
None.

## OUTPUTS
The created Service Desk ticket object or `$null` when no events exceed the threshold.

## NOTES
