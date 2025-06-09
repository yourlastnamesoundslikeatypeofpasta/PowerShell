# Quickstart Guide

This short guide shows the basic steps to start using the modules in this repository.

1. **Clone the repository**
   ```powershell
 git clone <internal repo URL>
 cd PowerShell
  ```
2. **Install required dependencies**
   ```powershell
   ./scripts/Install-ModuleDependencies.ps1
   ```
3. **Update installed modules** (optional)
   ```powershell
   ./scripts/Update-ModuleDependencies.ps1
   ```
4. **Start the local mock API server** (optional)
   ```powershell
   ./scripts/Start-MockApiServer.ps1
   ```
5. **Install from internal repository (optional)**
   ```powershell
   ./scripts/Install-SupportTools.ps1
   ```
    The script imports `Logging`, `Telemetry`, `IncidentResponseTools`,
    `SharePointTools`, `ServiceDeskTools` and `SupportTools` from the `src`
    folder.
6. **Import the modules**
   ```powershell
   Import-Module ./src/SupportTools/SupportTools.psd1
   Import-Module ./src/SharePointTools/SharePointTools.psd1
   Import-Module ./src/ServiceDeskTools/ServiceDeskTools.psd1
   ```
7. **Validate SharePoint prerequisites**
   ```powershell
   ./scripts/Test-SPToolsPrereqs.ps1 -Install
   ```
8. **Run configuration** (for SharePoint functions)
   ```powershell
   ./scripts/Configure-SharePointTools.ps1
   ```
9. **Load credentials** (optional)
   Refer to [CredentialStorage.md](CredentialStorage.md) for a step‑by‑step
   walkthrough of using SecretManagement to load environment variables.
10. **Try a few common commands**
   ```powershell
   # System information
   Get-CommonSystemInfo | Format-Table

   # Generate a document library report
   Get-SPToolsAllLibraryReports | Format-Table

   # Create a Service Desk ticket
   New-SDTicket -Title "Test" -Description "Quick start test"
   ```
11. **Launch an interactive menu** (optional)
   ```powershell
   # Common SupportTools tasks
   ./scripts/SupportToolsMenu.ps1 -UserRole Helpdesk

   # Browse any script in the repository
   ./scripts/ScriptLauncher.ps1
   ```

See [docs/UserGuide.md](UserGuide.md) for detailed deployment and usage instructions.
