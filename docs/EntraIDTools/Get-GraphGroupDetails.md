---
external help file: EntraIDTools-help.xml
Module Name: EntraIDTools
online version:
schema: 2.0.0
---

# Get-GraphGroupDetails

## SYNOPSIS
Retrieves the group's name, description and members via the Microsoft Graph API.

## SYNTAX
```powershell
Get-GraphGroupDetails [-GroupId] <String> [-TenantId] <String> [-ClientId] <String> [-ClientSecret <String>] [<CommonParameters>]
```

## DESCRIPTION
Authenticates against Microsoft Graph and queries the specified group for its
basic information and membership list. Activity is logged and telemetry is
recorded.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-GraphGroupDetails -GroupId 00000000-0000-0000-0000-000000000000 -TenantId <tenant-id> -ClientId <app-id>
```
Retrieves details for the group and displays them in the console.

## PARAMETERS

### -GroupId
Identifier of the group to retrieve.

### -TenantId
GUID identifier for the Azure AD tenant containing the group.

### -ClientId
Application (client) ID used for Microsoft Graph authentication.

### -ClientSecret
Optional client secret for app-only authentication.

### CommonParameters
This cmdlet supports the common parameters: `-Debug`, `-ErrorAction`, `-ErrorVariable`, `-InformationAction`, `-InformationVariable`, `-OutVariable`, `-OutBuffer`, `-PipelineVariable`, `-Verbose`, `-WarningAction`, and `-WarningVariable`.

## INPUTS
None.

## OUTPUTS
A PSCustomObject describing the group.

## NOTES
