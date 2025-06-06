# Internal IT Deployment Guide

This guide explains how to set up and use the **SupportTools** and **SharePointTools** modules contained in this repository.

## Requirements

* **PowerShell 7** or later
* Required dependencies when running specific commands:
* `PnP.PowerShell` for SharePoint cleanup functions. See the [official PnP PowerShell documentation](https://pnp.github.io/powershell/index.html) for connection and usage guidance.
  * `ExchangeOnlineManagement` for mailbox functions
* `MicrosoftPlaces` for the `Invoke-CompanyPlaceManagement` command

Ensure the modules above are installed prior to running the included commands.
You can run `./scripts/Install-ModuleDependencies.ps1` to automatically check
for and install any missing dependencies.

## Obtaining the Modules

Clone or download this repository to a location accessible by your team:

```powershell
# Example clone
git clone <repository-url>
```

The modules are located under the `src` folder:

```
src/SupportTools
src/SharePointTools
```

## Importing Modules

Import the modules using their manifest files (`.psd1`):

```powershell
Import-Module ./src/SupportTools/SupportTools.psd1
Import-Module ./src/SharePointTools/SharePointTools.psd1
```

Run the configuration script once to store your SharePoint application details and configure the SharePoint site URLs to target:

```powershell
./scripts/Configure-SharePointTools.ps1
```

You can place these commands in your profile or deployment scripts so the functions are available in each session.

## Running Commands

After importing, call any of the exported functions. A few examples:

```powershell
# Retrieve system information
Get-CommonSystemInfo | Format-Table -AutoSize

# Remove archived SharePoint folders
Invoke-YFArchiveCleanup -Verbose

# Manage the site list
Add-SPToolsSite -Name 'ContosoHR' -Url 'https://contoso.sharepoint.com/sites/HR'

# Generate a document library report for all configured sites
Get-SPToolsAllLibraryReports | Format-Table
# Review recycle bin usage for all sites
Get-SPToolsAllRecycleBinReports | Format-Table
# Review Preservation Hold Library size for all sites
Get-SPToolsAllPreservationHoldReports | Format-Table
# Clear both recycle bin stages for a site
Clear-SPToolsRecycleBin -SiteName 'ContosoHR' -SecondStage
# Configure auto-reply on a shared mailbox
$start = Get-Date '2025-06-02T00:00:00'
$end   = Get-Date '2025-06-09T23:59:59'
Set-SharedMailboxAutoReply -MailboxIdentity 'team@contoso.com' \
    -StartTime $start -EndTime $end \
    -InternalMessage 'Out of office' \ 
    -ExternalMessage 'Out of office' \ 
    -AdminUser 'admin@contoso.com'
```

For descriptions of all scripts included in the SupportTools wrapper module see [scripts/README.md](../scripts/README.md). Example usage scripts are provided in the `Examples` folder.

## Security Considerations

### Secrets Management

Do not store client IDs, tenant identifiers, or certificate paths directly in scripts. Instead, define the following environment variables before using the SharePoint tools module:

```text
SPTOOLS_CLIENT_ID
SPTOOLS_TENANT_ID
SPTOOLS_CERT_PATH
```

These values override settings from `config/SharePointToolsSettings.psd1` so credentials remain outside of source control.

## Updating

If the repository is updated, pull the latest changes and re-import the modules. Incremented module versions are defined in the manifest files.

## Support

These modules are provided as-is for internal use. Review the code and adjust the scripts to match your environment and compliance requirements.

