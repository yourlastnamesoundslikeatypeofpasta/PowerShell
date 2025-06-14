# SupportTools PowerShell Modules

[![Pester Tests](https://github.com/yourlastnamesoundslikeatypeofpasta/PowerShell/actions/workflows/pester-tests.yml/badge.svg)](https://github.com/yourlastnamesoundslikeatypeofpasta/PowerShell/actions/workflows/pester-tests.yml)

This repository packages a collection of scripts into reusable modules.

* **SupportTools** – general helper commands that wrap the scripts in the `/scripts` folder.
* **IncidentResponseTools** – commands focused on auditing and incident response tasks.
* **ConfigManagementTools** – commands for configuring systems and services.
* **SharePointTools** – commands for SharePoint cleanup tasks such as removing archives or sharing links.
* **ServiceDeskTools** – interact with the Service Desk ticketing system.
* **PerformanceTools** – measure script runtime and resource usage.
* **EntraIDTools** – query Microsoft Graph for account details such as license assignments, group membership and sign-in history.
* **ChaosTools** – inject random delays and failures to test error handling.
* **STPlatform** – initialize modules for cloud, hybrid or on-prem environments.

### Module Maturity

| Module | Status |
| ------ | ------ |
| SupportTools | Stable |
| IncidentResponseTools | Beta |
| ConfigManagementTools | Beta |
| SharePointTools | Stable |
| ServiceDeskTools | Beta |
| PerformanceTools | Beta |
| EntraIDTools | Stable |
| ChaosTools | Beta |
| STPlatform | Beta |

## Requirements 📋

* **PowerShell 7 or later** must be installed to import these modules. Check your
  version with `$PSVersionTable.PSVersion` and upgrade if the major version is
  less than 7.
* Specific commands rely on additional modules:
  * `PnP.PowerShell` for SharePoint cleanup functions. See the [official PnP PowerShell documentation](https://pnp.github.io/powershell/index.html) for connection and usage guidance.
  * `ExchangeOnlineManagement` for mailbox automation such as `Set-SharedMailboxAutoReply`.
  * `MicrosoftPlaces` for the `Invoke-CompanyPlaceManagement` command.
* Several scripts assume **tenant administrator permissions** to connect to the target SharePoint or Exchange Online environment. Review each script's notes and ensure you have the required access before running them.

## First-Time Install 🚀

For a brand new environment clone the repo and run the helper scripts to set up dependencies and install the modules. Wrapping the commands in a `try/catch` block helps surface any errors during setup:

```powershell
git clone https://github.com/yourlastnamesoundslikeatypeofpasta/PowerShell.git
cd PowerShell
try {
    ./scripts/Install-ModuleDependencies.ps1
    ./scripts/Install-SupportTools.ps1

} catch {
    Write-Error $_
}
```

Ensure the `PSReadLine` module is loaded to enable tab completion of parameter
names when working interactively:

```powershell
Import-Module PSReadLine
```

`Install-SupportTools.ps1` imports the modules directly from the `src` folder. Next run the SharePoint configuration script if you plan to use those commands:

```powershell
./scripts/Test-SPToolsPrereqs.ps1 -Install
./scripts/Configure-SharePointTools.ps1 -ClientId <appId> -TenantId <tenantId> -CertPath <path>
```

You can provide `-ClientId`, `-TenantId` and `-CertPath` via the environment
variables `SPTOOLS_CLIENT_ID`, `SPTOOLS_TENANT_ID` and `SPTOOLS_CERT_PATH` or by
loading them from your SecretManagement vault.


## Installation 📦

Install the modules from your internal repository:

```powershell
Install-Module SupportTools -Repository MyInternalRepo
Install-Module SharePointTools -Repository MyInternalRepo
Install-Module ServiceDeskTools -Repository MyInternalRepo
Install-Module PerformanceTools -Repository MyInternalRepo
Install-Module EntraIDTools -Repository MyInternalRepo
Install-Module ChaosTools -Repository MyInternalRepo
```

If your repository isn't registered yet, run `Register-PSRepository` with the feed URL before installing.

If you'd rather work from source, clone the repo and import the manifests:

```powershell
git clone https://github.com/yourlastnamesoundslikeatypeofpasta/PowerShell.git
if (Test-Path ./src/SupportTools/SupportTools.psd1) {
    Import-Module ./src/SupportTools/SupportTools.psd1
}
if (Test-Path ./src/SharePointTools/SharePointTools.psd1) {
    Import-Module ./src/SharePointTools/SharePointTools.psd1
}
if (Test-Path ./src/ServiceDeskTools/ServiceDeskTools.psd1) {
    Import-Module ./src/ServiceDeskTools/ServiceDeskTools.psd1
}
if (Test-Path ./src/PerformanceTools/PerformanceTools.psd1) {
    Import-Module ./src/PerformanceTools/PerformanceTools.psd1
}
if (Test-Path ./src/EntraIDTools/EntraIDTools.psd1) {
    Import-Module ./src/EntraIDTools/EntraIDTools.psd1
}
if (Test-Path ./src/ChaosTools/ChaosTools.psd1) {
    Import-Module ./src/ChaosTools/ChaosTools.psd1
}
```

Each `Import-Module` call verifies the module path first to avoid errors when a
directory is missing.

For SharePoint operations run:

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

### EntraIDTools example

```powershell
Get-GraphUserDetails -UserPrincipalName 'user@contoso.com' -TenantId <tenantId> -ClientId <appId> -CsvPath ./details.csv
```
The command gathers basic profile information, assigned licenses, group membership and last sign-in time. Results can be exported to CSV or HTML for reporting.
`Get-GraphUserDetails` also accepts `TenantId` and `ClientId` via the
`SPTOOLS_TENANT_ID` and `SPTOOLS_CLIENT_ID` environment variables or through a
SecretManagement vault.

See [docs/SupportTools.md](docs/SupportTools.md), [docs/IncidentResponseTools.md](docs/IncidentResponseTools.md), [docs/ConfigManagementTools.md](docs/ConfigManagementTools.md), [docs/SharePointTools.md](docs/SharePointTools.md), [docs/ServiceDeskTools.md](docs/ServiceDeskTools.md), [docs/PerformanceTools.md](docs/PerformanceTools.md), [docs/EntraIDTools.md](docs/EntraIDTools.md), [docs/ChaosTools.md](docs/ChaosTools.md) and [docs/STPlatform/Connect-STPlatform.md](docs/STPlatform/Connect-STPlatform.md) for a full list of commands. For a short introduction refer to [docs/Quickstart.md](docs/Quickstart.md). For detailed deployment guidance see [docs/UserGuide.md](docs/UserGuide.md).

The module also provides `Set-SharedMailboxAutoReply` for configuring automatic
out-of-office replies on a shared mailbox.
The module now includes `Invoke-CompanyPlaceManagement` for administering Microsoft Places buildings and floors.
Functions like `Add-SPToolsSite` and `Remove-SPToolsSite` let you manage the list of SharePoint sites stored in the settings file.

For a list of the wrapped scripts and their descriptions see [scripts/README.md](scripts/README.md).
### ServiceDeskTools example

```powershell
Search-SDTicket -Query 'printer issue'
```

### PerformanceTools example

```powershell
Measure-STCommand { Get-Process }
```

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
SD_ASSET_BASE_URI
```

When set, these variables override values stored in `config/SharePointToolsSettings.psd1`.
`Connect-STPlatform` now checks the registered SecretManagement vault for these variables
when they are missing and loads them automatically. See
[docs/CredentialStorage.md](docs/CredentialStorage.md) for configuring a vault.
Set `ST_CHAOS_MODE` to `1` or use the `-ChaosMode` switch on ServiceDeskTools commands to simulate throttled or failing API calls during testing.
For a step-by-step example of loading these variables from the SecretManagement
module see [docs/CredentialStorage.md](docs/CredentialStorage.md).

## Centralized Logging 📝

Commands automatically record their activity to `%USERPROFILE%\SupportToolsLogs\supporttools.log` by default or to `$env:ST_LOG_PATH` when set.
Use the `-Path` parameter of `Write-STLog` to log elsewhere as needed.
Use `-Structured` or set `ST_LOG_STRUCTURED=1` to emit rich JSON events that include user and script metadata.
Set `ST_LOG_LEVEL` to control the minimum severity written to the log (INFO, WARN or ERROR).
Set `ST_LOG_ENCRYPT=1` to encrypt log files with the current user's credentials.
For the schema of these structured entries see [docs/Logging/RichLogFormat.md](docs/Logging/RichLogFormat.md).
Use `-MaxSizeMB` and `-MaxFiles` with `Write-STLog` to control log rotation. Logs over the size limit (default 1 MB) are renamed with incrementing numeric suffixes.
Use `-Metric` and `-Value` with `Write-STLog` to capture performance data like durations.
Review the resulting log file with `Get-Content` when troubleshooting.
## Running Tests 🧪

Install Pester if it's not already available and run the suite from the repository root:

```powershell
Install-Module Pester -MinimumVersion 5.0 -Scope CurrentUser
Invoke-Pester -Configuration (Import-PowerShellDataFile ./PesterConfiguration.psd1)
```
For a completely clean environment run `./setup.sh` first. The script installs
PowerShell 7.4.1, sets up Pester globally and then runs the tests using the
same configuration.
For conventions on writing new tests see [docs/TestingGuidelines.md](docs/TestingGuidelines.md).

## Roadmap 🛣️

Potential areas for improvement and extension include:

1. ~~**Dependency Management**
   Automate installation or checks for required modules to streamline setup and
   provide clear guidance when dependencies are missing.~~ - Dependencies can now
   be installed with [scripts/Install-ModuleDependencies.ps1](scripts/Install-ModuleDependencies.ps1). A
   proposed improvement is a preflight script that verifies required modules are
   present and offers to install any that are missing.
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
    Convert module functions into full advanced functions with `[CmdletBinding(SupportsShouldProcess)]`,
    parameter validation attributes such as `ValidateSet` and `ValidateNotNullOrEmpty`,
    and support for pipeline input. Add dynamic argument completers for easier
    interactive use.

## License

This project is licensed under the [MIT License](LICENSE).
See the [CHANGELOG.md](CHANGELOG.md) for release history.

## Contributing

Contributions are welcome! This repo is maintained internally for our team, but collaborators are encouraged to open issues or submit pull requests. Please follow the style outlined in [docs/ModuleStyleGuide.md](docs/ModuleStyleGuide.md) and include tests when possible.

