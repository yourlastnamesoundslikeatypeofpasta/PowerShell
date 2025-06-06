# PowerShell Scripts

These scripts are wrapped by the `SupportTools` module. Import the module and invoke the functions directly rather than running the `.ps1` files.

The following table provides a brief description of each script.

| Script | Description |
|-------|-------------|
| **AddUsersToGroup.ps1** | Adds users from a CSV file to a Microsoft 365 group using Microsoft Graph. |
| **CleanupArchive.ps1** | Deletes files and folders inside the `zzz_Archive_Production` directory of a SharePoint library. |
| **Convert-ExcelToCsv.ps1** | Converts Excel files to CSV format. |
| **Get-CommonSystemInfo.ps1** | Retrieves operating system, processor, memory and disk information. |
| **Get-FailedLogins.ps1** | Displays failed logon events (ID 4625) from the Security event log. |
| **Get-NetworkShares.ps1** | Lists network shares on a specified computer. |
| **Get-UniquePermissions.ps1** | Identifies SharePoint items with unique permissions by bypassing the 5000 item view limit. |
| **Install-Fonts.ps1** | Installs fonts from a folder for all users. |
| **PostInstallScript.ps1** | Automates Windows setup tasks such as installing applications and joining a domain. |
| **ProductKey.ps1** | Retrieves the Windows product key and exports it to a file. |
| **Search-ReadMe.ps1** | Recursively searches the system for a readme file. |
| **Set-ComputerIPAddress.ps1** | Sets static IP addresses based on data from a CSV file. |
| **Set-NetAdapterMetering.ps1** | Adjusts the interface metric for specified network adapters. |
| **Set-TimeZoneEasternStandardTime.ps1** | Sets the system time zone to Eastern Standard Time. |
| **SimpleCountdown.ps1** | Outputs a simple countdown from 10 to 1. |
| **Update-Sysmon.ps1** | Reinstalls Sysmon from a removable drive and verifies it is running. |
| **Submit-SystemInfoTicket.ps1** | Collects system info, uploads it to SharePoint and opens a Service Desk ticket. |
| **SS_DEPLOYMENT_TEMPLATE.ps1** | Template for sneaker net deployments that installs agents and configures a system. |
| **Configure-SharePointTools.ps1** | Prompts for SharePoint application values and saves them to a settings file. |
| **CleanupTempFiles.ps1** | Removes .tmp files and empty logs from the repository. |
| **Setup-ScheduledMaintenance.ps1** | Generates Task Scheduler XML for weekly maintenance tasks. |
