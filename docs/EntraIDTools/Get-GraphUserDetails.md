---
external help file: EntraIDTools-help.xml
Module Name: EntraIDTools
online version:
schema: 2.0.0
---

# Get-GraphUserDetails

## SYNOPSIS
Retrieves details such as display name, licenses, groups and sign-in activity for a specified user via the Microsoft Graph API.

## SYNTAX
```powershell
Get-GraphUserDetails [-UserPrincipalName] <String> [-TenantId] <String> [-ClientId] <String> [-ClientSecret <String>] [-CsvPath <String>] [-HtmlPath <String>] [<CommonParameters>]
```

## DESCRIPTION
Authenticates using MSAL and queries Graph for the user's basic information, assigned licenses, group membership and last sign-in time. Optionally exports the results to CSV and/or HTML. Activity is logged and telemetry is recorded.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-GraphUserDetails -UserPrincipalName user@contoso.com -TenantId <tenant-id> -ClientId <app-id>
```
Retrieves the user's details and displays them in the console.

### Example 2
```powershell
PS C:\> Get-GraphUserDetails -UserPrincipalName user@contoso.com -TenantId <tenant-id> -ClientId <app-id> -CsvPath ./user.csv -HtmlPath ./user.html
```
Exports the user's details to both CSV and HTML files.

## PARAMETERS

### -UserPrincipalName
User principal name (UPN) of the account to retrieve.

### -TenantId
GUID identifier for the Azure AD tenant containing the user.
Alias: `TenantID`, `tenantId`

### -ClientId
Application (client) ID used for Microsoft Graph authentication.

### -ClientSecret
Optional client secret for app-only authentication.

### -CsvPath
Optional file path to save the returned details as a CSV file.

### -HtmlPath
Optional file path to save the returned details as an HTML report.

### CommonParameters
This cmdlet supports the common parameters: `-Debug`, `-ErrorAction`, `-ErrorVariable`, `-InformationAction`, `-InformationVariable`, `-OutVariable`, `-OutBuffer`, `-PipelineVariable`, `-Verbose`, `-WarningAction`, and `-WarningVariable`.

## INPUTS
None.

## OUTPUTS
A PSCustomObject describing the user.

## NOTES
