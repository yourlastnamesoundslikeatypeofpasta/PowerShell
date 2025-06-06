# SupportTools PowerShell Modules

This repository packages a collection of scripts into reusable modules.

* **SupportTools** – general helper commands that wrap the scripts in the `/scripts` folder.
* **SharePointTools** – commands for SharePoint cleanup tasks such as removing archives or sharing links.
* **ServiceDeskTools** – interact with the Service Desk ticketing system.

## Requirements

* **PowerShell 7 or later** must be installed to import these modules.
* Specific commands rely on additional modules:
  * `PnP.PowerShell` for SharePoint cleanup functions. See the [official PnP PowerShell documentation](https://pnp.github.io/powershell/index.html) for connection and usage guidance.
  * `ExchangeOnlineManagement` for mailbox automation such as `Set-SharedMailboxAutoReply`.
  * `MicrosoftPlaces` for the `Invoke-CompanyPlaceManagement` command.
* Several scripts assume **tenant administrator permissions** to connect to the target SharePoint or Exchange Online environment. Review each script's notes and ensure you have the required access before running them.

## Installation

1. Clone or download this repository:

   ```powershell
   git clone <repository-url>
   ```

2. Import the module manifest files from the `src` folder:

   ```powershell
   Import-Module ./src/SupportTools/SupportTools.psd1
   Import-Module ./src/SharePointTools/SharePointTools.psd1
   Import-Module ./src/ServiceDeskTools/ServiceDeskTools.psd1
   ```

3. Run the SharePoint configuration script once to store tenant information:

   ```powershell
   ./scripts/Configure-SharePointTools.ps1
   ```

## Usage

Once installed, the modules expose a variety of helper commands. The most common examples are shown below.

### SupportTools example

```powershell
Get-CommonSystemInfo
Set-SharedMailboxAutoReply -MailboxIdentity 'team@contoso.com' -StartTime (Get-Date) -EndTime (Get-Date).AddDays(7) -InternalMessage 'Out of office' -AdminUser 'admin@contoso.com'
```

### SharePointTools example

```powershell
Invoke-YFArchiveCleanup -Verbose
Get-SPToolsAllLibraryReports | Format-Table
```

See [docs/SupportTools.md](docs/SupportTools.md), [docs/SharePointTools.md](docs/SharePointTools.md) and [docs/ServiceDeskTools.md](docs/ServiceDeskTools.md) for a full list of commands. For deployment guidance consult [docs/UserGuide.md](docs/UserGuide.md).

The module also provides `Set-SharedMailboxAutoReply` for configuring automatic
out-of-office replies on a shared mailbox.
The module now includes `Invoke-CompanyPlaceManagement` for administering Microsoft Places buildings and floors.
Functions like `Add-SPToolsSite` and `Remove-SPToolsSite` let you manage the list of SharePoint sites stored in the settings file.

For a list of the wrapped scripts and their descriptions see [scripts/README.md](scripts/README.md).
Example scripts for every function can be found in the `/Examples` folder.

## Documentation

For help using Microsoft Graph cmdlets, see the official [Microsoft Graph PowerShell documentation](https://learn.microsoft.com/en-us/powershell/microsoftgraph/get-started?view=graph-powershell-1.0).

## Security Considerations

### Secrets Management

Avoid hardcoding credentials or certificate paths within scripts. The SharePoint tools module can read the following environment variables to provide connection details securely:

```text
SPTOOLS_CLIENT_ID
SPTOOLS_TENANT_ID
SPTOOLS_CERT_PATH
```

ServiceDeskTools reads the following variables for API access:

```text
SD_API_TOKEN
SD_BASE_URI
```

When set, these variables override values stored in `config/SharePointToolsSettings.psd1`.

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
