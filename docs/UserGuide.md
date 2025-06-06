# Internal IT Deployment Guide

This guide explains how to set up and use the **SupportTools** and **SharePointTools** modules contained in this repository.

## Requirements

* **PowerShell 7** or later
* Required dependencies when running specific commands:
  * `PnP.PowerShell` for SharePoint cleanup functions
  * `ExchangeOnlineManagement` for mailbox functions
* `MicrosoftPlaces` for the `Invoke-CompanyPlaceManagement` command

Ensure the modules above are installed prior to running the included commands.

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

## Updating

If the repository is updated, pull the latest changes and re-import the modules. Incremented module versions are defined in the manifest files.

## Support

These modules are provided as-is for internal use. Review the code and adjust the scripts to match your environment and compliance requirements.

