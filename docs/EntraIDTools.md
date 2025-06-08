# EntraIDTools Module

Commands that query Microsoft Graph for tenant data. Import the module:

```powershell
Import-Module ./src/EntraIDTools/EntraIDTools.psd1
```

This module depends on the **MSAL.PS** module which provides the `Get-MsalToken`
command used for authentication. Install the dependency from the PowerShell
Gallery first:

```powershell
Install-Module MSAL.PS
```

## Available Commands

| Command | Description | Example |
|---------|-------------|---------|
| `Get-GraphUserDetails` | Retrieve metadata for a user | `Get-GraphUserDetails -UserPrincipalName user@contoso.com -TenantId <tenant> -ClientId <app>` |
| `Get-GraphGroupDetails` | Retrieve metadata for a group | `Get-GraphGroupDetails -GroupId <id> -TenantId <tenant> -ClientId <app>` |

The command requires an Entra ID application registration. Provide the tenant ID, client ID and optional client secret for authentication.

You can also set the following environment variables so parameters aren't required on every call:

- `GRAPH_TENANT_ID` – the tenant ID to authenticate against
- `GRAPH_CLIENT_ID` – the application (client) ID
- `GRAPH_CLIENT_SECRET` – optional client secret

When these variables are present, `Get-GraphUserDetails` and other commands will use them automatically.

