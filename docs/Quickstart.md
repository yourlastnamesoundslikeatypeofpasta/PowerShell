# Quickstart Guide

This short guide shows the basic steps to start using the modules in this repository.

1. **Clone the repository**
   ```powershell
 git clone <repository-url>
 cd PowerShell
  ```
2. **Install required dependencies**
   ```powershell
   ./scripts/Install-ModuleDependencies.ps1
   ```
3. **Start the local mock API server** (optional)
   ```powershell
   ./scripts/Start-MockApiServer.ps1
   ```
4. **Install from gallery (optional)**
   ```powershell
   ./scripts/Install-SupportTools.ps1 -SupportToolsVersion 1.3.0
   ```
5. **Import the modules**
   ```powershell
   Import-Module ./src/SupportTools/SupportTools.psd1
   Import-Module ./src/SharePointTools/SharePointTools.psd1
   Import-Module ./src/ServiceDeskTools/ServiceDeskTools.psd1
   ```
6. **Run configuration** (for SharePoint functions)
   ```powershell
   ./scripts/Configure-SharePointTools.ps1
   ```
7. **Load credentials** (optional)
   Refer to [CredentialStorage.md](CredentialStorage.md) for a step‑by‑step
   walkthrough of using SecretManagement to load environment variables.
8. **Try a few common commands**
   ```powershell
   # System information
   Get-CommonSystemInfo | Format-Table

   # Generate a document library report
   Get-SPToolsAllLibraryReports | Format-Table

   # Create a Service Desk ticket
   New-SDTicket -Title "Test" -Description "Quick start test"
   ```
9. **Launch the interactive menu** (optional)
   ```powershell
   ./scripts/SupportToolsMenu.ps1
   ```

See [docs/UserGuide.md](UserGuide.md) for detailed deployment and usage instructions.
