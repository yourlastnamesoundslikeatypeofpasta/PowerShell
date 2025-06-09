---
external help file: EntraIDTools-help.xml
Module Name: EntraIDTools
online version:
schema: 2.0.0
---

# Monitor-GraphSignIn

Monitor sign-in logs and create Service Desk tickets for risky events.

## SYNTAX
```powershell
Monitor-GraphSignIn [-UserPrincipalName <String>] [-StartTime <DateTime>] [-EndTime <DateTime>]
 [-TenantId] <String> [-ClientId] <String> [-ClientSecret <String>] [-RequesterEmail] <String>
 [-Threshold <String>] [-ChaosMode] [<CommonParameters>]
```

## DESCRIPTION
Combines `Get-GraphSignInLogs` with `New-SDTicket`. Sign-ins whose `riskLevelAggregated`
meets or exceeds `-Threshold` trigger ticket creation. Use `-ChaosMode` or set
`ST_CHAOS_MODE=1` to simulate failures during ticket creation.

## EXAMPLE
```powershell
PS C:\> Monitor-GraphSignIn -TenantId <tenant> -ClientId <app> -RequesterEmail 'admin@example.com'
```
Retrieves the last hour of sign-ins and opens Service Desk tickets for any high risk events.

## PARAMETERS
### -UserPrincipalName
UPN to filter sign-ins.

### -StartTime
Start of the time range. Defaults to one hour ago.

### -EndTime
End of the time range. Defaults to now.

### -TenantId
Tenant used for authentication.

### -ClientId
Application (client) ID for Graph authentication.

### -ClientSecret
Optional client secret for app-only auth.

### -RequesterEmail
Email address used for Service Desk tickets.

### -Threshold
Risk level that triggers ticket creation. Accepts Low, Medium or High.

### -ChaosMode
Enable chaos testing when creating tickets.

### CommonParameters
This cmdlet supports the common parameters: `-Debug`, `-ErrorAction`, `-ErrorVariable`,
`-InformationAction`, `-InformationVariable`, `-OutVariable`, `-OutBuffer`,
`-PipelineVariable`, `-Verbose`, `-WarningAction`, and `-WarningVariable`.

## INPUTS
None.

## OUTPUTS
An array of sign-in log objects.

## NOTES
