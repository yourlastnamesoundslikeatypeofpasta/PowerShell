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
3. **Import the modules**
   ```powershell
   Import-Module ./src/SupportTools/SupportTools.psd1
   Import-Module ./src/SharePointTools/SharePointTools.psd1
   Import-Module ./src/ServiceDeskTools/ServiceDeskTools.psd1
   ```
4. **Run configuration** (for SharePoint functions)
   ```powershell
   ./scripts/Configure-SharePointTools.ps1
   ```
5. **Load credentials** (optional)
   ```powershell
   # Example using SecretManagement
   . ./docs/CredentialStorage.md
   ```
6. **Try a few common commands**
   ```powershell
   # System information
   Get-CommonSystemInfo | Format-Table

   # Generate a document library report
   Get-SPToolsAllLibraryReports | Format-Table

   # Create a Service Desk ticket
   New-SDTicket -Title "Test" -Description "Quick start test"
   ```

See [docs/UserGuide.md](UserGuide.md) for detailed deployment and usage instructions.
