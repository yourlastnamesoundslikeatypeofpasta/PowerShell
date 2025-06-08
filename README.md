# SupportTools PowerShell Modules
[![Pester Tests](https://github.com/yourlastnamesoundslikeatypeofpasta/PowerShell/actions/workflows/pester-tests.yml/badge.svg)](https://github.com/yourlastnamesoundslikeatypeofpasta/PowerShell/actions/workflows/pester-tests.yml)


This repository packages a collection of scripts into reusable modules.

* **SupportTools** – general helper commands that wrap the scripts in the `/scripts` folder.
* **SharePointTools** – commands for SharePoint cleanup tasks such as removing archives or sharing links.
* **ServiceDeskTools** – interact with the Service Desk ticketing system.
* **PerformanceTools** – measure script runtime and resource usage.
* **GraphTools** – query Microsoft Graph for common account information.
* **ChaosTools** – inject random delays and failures to test error handling.

### Module Maturity

| Module | Status |
| ------ | ------ |
| SupportTools | Stable |
| SharePointTools | Stable |
| ServiceDeskTools | Experimental |
| PerformanceTools | Experimental |
| GraphTools | Experimental |
| ChaosTools | Experimental |

## Requirements 📋

* **PowerShell 7 or later** must be installed to import these modules.
* Specific commands rely on additional modules:
  * `PnP.PowerShell` for SharePoint cleanup functions. See the [official PnP PowerShell documentation](https://pnp.github.io/powershell/index.html) for connection and usage guidance.
  * `ExchangeOnlineManagement` for mailbox automation such as `Set-SharedMailboxAutoReply`.
  * `MicrosoftPlaces` for the `Invoke-CompanyPlaceManagement` command.
* Several scripts assume **tenant administrator permissions** to connect to the target SharePoint or Exchange Online environment. Review each script's notes and ensure you have the required access before running them.

## Installation 📦

1. Clone or download this repository:

   ```powershell
   git clone https://github.com/yourlastnamesoundslikeatypeofpasta/PowerShell.git
   ```

2. Install the published modules (optional):

   ```powershell
   ./scripts/Install-SupportTools.ps1 -SupportToolsVersion 1.3.0
   # or pin a specific build
   Install-Module -Name SupportTools -RequiredVersion 1.3.0
   ```
   The script attempts to download each module from the gallery and falls back
   to importing the versions under `src` if the gallery cannot be reached.

3. Import the module manifest files from the `src` folder:

   ```powershell
   Import-Module ./src/SupportTools/SupportTools.psd1
   Import-Module ./src/SharePointTools/SharePointTools.psd1
   Import-Module ./src/ServiceDeskTools/ServiceDeskTools.psd1
   Import-Module ./src/GraphTools/GraphTools.psd1
   ```

4. Validate the SharePoint dependency and save tenant information:

   ```powershell
   ./scripts/Test-SPToolsPrereqs.ps1 -Install
   ./scripts/Configure-SharePointTools.ps1 -ClientId <appId> -TenantId <tenantId> -CertPath <path>
   ```

## Usage 💡

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

### ChaosTools example

```powershell
Invoke-ChaosTest -ScriptBlock { Get-Service } -FailureRate 0.2
```

See [docs/SupportTools.md](docs/SupportTools.md), [docs/SharePointTools.md](docs/SharePointTools.md), [docs/ServiceDeskTools.md](docs/ServiceDeskTools.md), [docs/PerformanceTools.md](docs/PerformanceTools.md), [docs/GraphTools.md](docs/GraphTools.md) and [docs/ChaosTools.md](docs/ChaosTools.md) for a full list of commands. For a short introduction refer to [docs/Quickstart.md](docs/Quickstart.md). For detailed deployment guidance see [docs/UserGuide.md](docs/UserGuide.md).

The module also provides `Set-SharedMailboxAutoReply` for configuring automatic
out-of-office replies on a shared mailbox.
The module now includes `Invoke-CompanyPlaceManagement` for administering Microsoft Places buildings and floors.
Functions like `Add-SPToolsSite` and `Remove-SPToolsSite` let you manage the list of SharePoint sites stored in the settings file.

For a list of the wrapped scripts and their descriptions see [scripts/README.md](scripts/README.md).

## Documentation 📚

For help using Microsoft Graph cmdlets, see the official [Microsoft Graph PowerShell documentation](https://learn.microsoft.com/en-us/powershell/microsoftgraph/get-started?view=graph-powershell-1.0).
Additional module help topics are located in the [docs](docs/README.md) folder.

## Security Considerations 🛡️

### Secrets Management 🔑

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
Set `ST_CHAOS_MODE` to `1` or use the `-ChaosMode` switch on ServiceDeskTools commands to simulate throttled or failing API calls during testing.
For a step-by-step example of loading these variables from the SecretManagement
module see [docs/CredentialStorage.md](docs/CredentialStorage.md).

## Centralized Logging 📝

Commands automatically record their activity to `%USERPROFILE%\SupportToolsLogs\supporttools.log` by default.
Set the `ST_LOG_PATH` environment variable or use the `-Path` parameter of `Write-STLog` to write logs to a custom location.
Use `-Structured` to emit JSON lines that include the current user and script name for ingestion into tools like Azure Log Analytics.
Set `ST_LOG_STRUCTURED=1` to enable structured output without adding the switch each time.
Use `-Metric` and `-Value` with `Write-STLog` to capture performance data like durations.
Review the resulting log file with `Get-Content` when troubleshooting.

## Roadmap 🛣️

Potential areas for improvement and extension include:

1. ~~**Dependency Management**
   Automate installation or checks for required modules to streamline setup and
   provide clear guidance when dependencies are missing.~~ - Dependencies can now
   be installed with [scripts/Install-ModuleDependencies.ps1](scripts/Install-ModuleDependencies.ps1).
2. ~~**Testing and Continuous Integration**
   Add more Pester tests to cover complex functions and configure CI to run them
   automatically.~~ - Tests automated with GitHub Actions.
3. ~~**Documentation**
   Expand user guides and provide a quickstart summary for key commands.~~ - Quickstart guide added ([docs/Quickstart.md](docs/Quickstart.md)).
4. **Feature Enhancements**
   Continue expanding SupportTools and SharePointTools with additional automation.
5. **Versioning and Distribution**
   Package the modules for easier updates via an internal feed and consider
   publishing them to an internal repository.
6. ~~**Centralized Logging**
   Provide a consistent logging approach across all commands for easier troubleshooting.~~ - Commands now log to `%USERPROFILE%\SupportToolsLogs\supporttools.log`.
7. **Error Handling**
   Add standardized error handling and optional transcript output.
8. **Telemetry (Opt-In)**
   Track script usage patterns, failure rates and execution time.
   Set the `ST_ENABLE_TELEMETRY` environment variable to `1` to enable collection.
   Summarize results with `Get-STTelemetryMetrics` and optionally export to CSV or SQLite.
9. ~~**Configuration Guidance**
   Document a recommended workflow for securely storing credentials.~~ - Example
workflow added ([docs/CredentialStorage.md](docs/CredentialStorage.md)).
10. ~~**Linting and Code Quality**
   Check scripts with PSScriptAnalyzer on each commit.~~ - Linting automated via GitHub Actions.
11. **Cmdlet Design Improvements**
    Convert module functions into full advanced functions with parameter validation,
    `SupportsShouldProcess`, and dynamic argument completers for easier interactive use.

## License

This project is licensed under the [MIT License](LICENSE).

## Contributing

Contributions are welcome! If you have a bug fix or new feature, feel free to open
an issue or submit a pull request. Please ensure any new PowerShell code follows
the style outlined in [docs/ModuleStyleGuide.md](docs/ModuleStyleGuide.md). Test
coverage for new functionality is greatly appreciated.
