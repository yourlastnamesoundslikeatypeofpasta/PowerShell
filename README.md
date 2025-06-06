# SupportTools PowerShell Modules

This repository packages a collection of scripts into reusable modules.

* **SupportTools** – general helper commands that wrap the scripts in the `/scripts` folder.
* **SharePointTools** – commands for SharePoint cleanup tasks such as removing archives or sharing links.

## Requirements

* **PowerShell 7 or later** must be installed to import these modules.
* Specific commands rely on additional modules:
  * `PnP.PowerShell` for SharePoint cleanup functions.
  * `ExchangeOnlineManagement` for mailbox automation such as `Set-SharedMailboxAutoReply`.
  * `MicrosoftPlaces` for the `Manage-CompanyPlace` command.
* Several scripts assume **tenant administrator permissions** to connect to the target SharePoint or Exchange Online environment. Review each script's notes and ensure you have the required access before running them.

## Usage

Import the module you need and then run any of the exported commands.

```powershell
Import-Module ./src/SupportTools/SupportTools.psd1
Import-Module ./src/SharePointTools/SharePointTools.psd1
```

Before running any SharePoint cleanup commands, execute the configuration script
once to store your tenant details:

```powershell
./scripts/Configure-SharePointTools.ps1
```

Example command:

```powershell
Get-CommonSystemInfo
```
For deployment steps see [docs/UserGuide.md](docs/UserGuide.md).

The module also provides `Set-SharedMailboxAutoReply` for configuring automatic
out-of-office replies on a shared mailbox.
The module now includes `Manage-CompanyPlace` for administering Microsoft Places buildings and floors.

For a list of the wrapped scripts and their descriptions see [scripts/README.md](scripts/README.md).
Example scripts for every function can be found in the `/Examples` folder.
