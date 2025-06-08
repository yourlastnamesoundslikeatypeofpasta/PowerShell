# GraphTools Module

Commands that query Microsoft Graph for tenant data. Import the module:

```powershell
Import-Module ./src/GraphTools/GraphTools.psd1
```

## Available Commands

| Command | Description | Example |
|---------|-------------|---------|
| `Get-GraphUserDetails` | Retrieve metadata for a user | `Get-GraphUserDetails -UserPrincipalName user@contoso.com -TenantId <tenant> -ClientId <app> -CsvPath ./user.csv -HtmlPath ./user.html` |

The command requires an Entra ID application registration. Provide the tenant ID, client ID and optional client secret for authentication. Results can be exported to CSV and HTML files using `-CsvPath` and `-HtmlPath`.
