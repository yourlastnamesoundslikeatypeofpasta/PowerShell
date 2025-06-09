---
external help file: EntraIDTools-help.xml
Module Name: EntraIDTools
online version:
schema: 2.0.0
---

# Get-GraphRiskySignIns

## SYNOPSIS
Retrieves risky sign-in events from the Microsoft Graph identityProtection API.

## SYNTAX
```powershell
Get-GraphRiskySignIns [-TenantId] <String> [-ClientId] <String> [-ClientSecret <String>] [<CommonParameters>]
```

## DESCRIPTION
Authenticates with Microsoft Graph and queries the `/beta/identityProtection/riskySignIns` endpoint. Activity is logged and telemetry is recorded.

## EXAMPLES
### Example 1
```powershell
PS C:\> Get-GraphRiskySignIns -TenantId <tenant-id> -ClientId <app-id>
```
Retrieves risky sign-ins for the tenant using device code authentication.

## PARAMETERS
### -TenantId
GUID identifier for the Entra ID tenant containing the logs.
Alias: `TenantID`, `tenantId`

### -ClientId
Application (client) ID used for Microsoft Graph authentication.

### -ClientSecret
Optional client secret for app-only authentication.

### CommonParameters
This cmdlet supports the common parameters: `-Debug`, `-ErrorAction`, `-ErrorVariable`, `-InformationAction`, `-InformationVariable`, `-OutVariable`, `-OutBuffer`, `-PipelineVariable`, `-Verbose`, `-WarningAction`, and `-WarningVariable`.

## INPUTS
None.

## OUTPUTS
An array of risky sign-in objects.

## NOTES
