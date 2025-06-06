# SupportTools PowerShell Modules

This repository packages a collection of scripts into reusable modules.

* **SupportTools** – general helper commands that wrap the scripts in the `/scripts` folder.
* **SharePointTools** – commands for SharePoint cleanup tasks such as removing archives or sharing links.

## Requirements

* **PowerShell 7 or later** must be installed to import these modules.
* Specific commands rely on additional modules:
  * `PnP.PowerShell` for SharePoint cleanup functions. See the [official PnP PowerShell documentation](https://pnp.github.io/powershell/index.html) for connection and usage guidance.
  * `ExchangeOnlineManagement` for mailbox automation such as `Set-SharedMailboxAutoReply`.
  * `MicrosoftPlaces` for the `Invoke-CompanyPlaceManagement` command.
* Several scripts assume **tenant administrator permissions** to connect to the target SharePoint or Exchange Online environment. Review each script's notes and ensure you have the required access before running them.

## Usage

Import the module you need and then run any of the exported commands.

```powershell
Import-Module ./src/SupportTools/SupportTools.psd1
Import-Module ./src/SharePointTools/SharePointTools.psd1
```

Before running any SharePoint cleanup commands, execute the configuration script
once to store your tenant details and define the SharePoint site URLs used by the module:

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
The module now includes `Invoke-CompanyPlaceManagement` for administering Microsoft Places buildings and floors.
Functions like `Add-SPToolsSite` and `Remove-SPToolsSite` let you manage the list of SharePoint sites stored in the settings file.

Use `Get-SPToolsSiteAdmins` to list the site collection administrators for any stored site.
For a list of the wrapped scripts and their descriptions see [scripts/README.md](scripts/README.md).
Example scripts for every function can be found in the `/Examples` folder.

## Documentation

For help using Microsoft Graph cmdlets, see the official [Microsoft Graph PowerShell documentation](https://learn.microsoft.com/en-us/powershell/microsoftgraph/get-started?view=graph-powershell-1.0).

## Roadmap

Potential areas for improvement and extension include:

1. **Dependency Management**  
   Automate installation or checks for required modules to streamline setup.
2. **Testing and Continuous Integration**  
   Add more Pester tests and configure CI to run them automatically.
3. **Documentation**  
   Expand user guides and provide a quickstart summary for key commands.
4. **Feature Enhancements**  
   Continue expanding SupportTools and SharePointTools with additional automation.
5. **Versioning and Distribution**  
   Package the modules for easier updates via an internal feed.
