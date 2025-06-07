# SupportTools Module

This module exposes helper commands that wrap the scripts located in the `scripts` folder.
Import the module and run the desired function rather than calling the script directly.

```powershell
Import-Module ./src/SupportTools/SupportTools.psd1
```

For a guided experience, run `./scripts/SupportToolsMenu.ps1` with the optional
`-UserRole` parameter to select common tasks from an interactive menu tailored
for `Helpdesk` or `Site Admin` roles. To browse and execute any script in the
repository, use `./scripts/ScriptLauncher.ps1` for a general menu of options.

### Simulation Mode

All commands now accept a `-Simulate` switch. When used, the command logs each
step and returns randomized mock data without making changes. This is useful for
testing in lab environments.

### Learning Mode

Use the `-Explain` switch with any command to view the underlying script's
full help content instead of executing it. This is useful when training new
administrators on what each task does.

## Available Commands

The table below lists each command and the script it invokes. Arguments not
listed are forwarded to the underlying script unchanged.

| Command | Wrapped Script | Key Parameters | Example |
|---------|----------------|---------------|---------|
| `Add-UserToGroup` | `AddUsersToGroup.ps1` | `CsvPath`, `GroupName` | `Add-UserToGroup -CsvPath users.csv -GroupName 'Team'` |
| `Invoke-GroupMembershipCleanup` | `CleanupGroupMembership.ps1` | `CsvPath`, `GroupName` | `Invoke-GroupMembershipCleanup -CsvPath remove.csv -GroupName 'Team'` |
| `Clear-ArchiveFolder` | `CleanupArchive.ps1` | *passthrough* | `Clear-ArchiveFolder -SiteUrl https://contoso.sharepoint.com/sites/Files` |
| `Restore-ArchiveFolder` | `RollbackArchive.ps1` | `SnapshotPath`, `SiteUrl` | `Restore-ArchiveFolder -SiteUrl https://contoso.sharepoint.com/sites/Files -SnapshotPath preDeleteLog.json` |
| `Convert-ExcelToCsv` | `Convert-ExcelToCsv.ps1` | *passthrough* | `Convert-ExcelToCsv -Path workbook.xlsx` |
| `Export-ProductKey` | `ProductKey.ps1` | *passthrough* | `Export-ProductKey` |
| `Get-CommonSystemInfo` | *built-in* | - | `Get-CommonSystemInfo` |
| `Get-FailedLogin` | `Get-FailedLogins.ps1` | *passthrough* | `Get-FailedLogin -ComputerName PC1` |
| `Get-NetworkShare` | `Get-NetworkShares.ps1` | *passthrough* | `Get-NetworkShare -ComputerName FS01` |
| `Get-UniquePermission` | `Get-UniquePermissions.ps1` | *passthrough* | `Get-UniquePermission -SiteUrl https://contoso.sharepoint.com/sites/HR` |
| `Install-Font` | `Install-Fonts.ps1` | *passthrough* | `Install-Font -Source C:\Fonts` |
| `Invoke-DeploymentTemplate` | `SS_DEPLOYMENT_TEMPLATE.ps1` | *passthrough* | `Invoke-DeploymentTemplate -Verbose` |
| `Invoke-ExchangeCalendarManager` | `ExchangeCalendarManager.ps1` | *interactive* | `Invoke-ExchangeCalendarManager` |
| `Invoke-PostInstall` | `PostInstallScript.ps1` | *passthrough* | `Invoke-PostInstall -Domain contoso.com` |
| `Search-ReadMe` | `Search-ReadMe.ps1` | *passthrough* | `Search-ReadMe -Pattern 'setup'` |
| `Set-ComputerIPAddress` | `Set-ComputerIPAddress.ps1` | *passthrough* | `Set-ComputerIPAddress -CsvPath ip.csv` |
| `Set-NetAdapterMetering` | `Set-NetAdapterMetering.ps1` | *passthrough* | `Set-NetAdapterMetering -AdapterName Ethernet0` |
| `Set-SharedMailboxAutoReply` | `Set-SharedMailboxAutoReply.ps1` | `MailboxIdentity`, `StartTime`, `EndTime`, `InternalMessage`, `[ExternalMessage]`, `[ExternalAudience]`, `AdminUser`, `[UseWebLogin]` | `Set-SharedMailboxAutoReply -MailboxIdentity help@contoso.com -StartTime (Get-Date) -EndTime (Get-Date).AddDays(7) -InternalMessage 'OOO' -AdminUser admin@contoso.com` |
| `Set-TimeZoneEasternStandardTime` | `Set-TimeZoneEasternStandardTime.ps1` | *passthrough* | `Set-TimeZoneEasternStandardTime` |
| `Start-Countdown` | `SimpleCountdown.ps1` | *passthrough* | `Start-Countdown -Seconds 30` |
| `Update-Sysmon` | `Update-Sysmon.ps1` | *passthrough* | `Update-Sysmon -SourcePath D:\Tools` |
| `Invoke-IncidentResponse` | `Invoke-IncidentResponse.ps1` | *passthrough* | `Invoke-IncidentResponse` |
| `Invoke-CompanyPlaceManagement` | `Invoke-CompanyPlaceManagement.ps1` | `Action`, `DisplayName`, `[Type]`, `Street`, `City`, `State`, `PostalCode`, `CountryOrRegion`, `[AutoAddFloor]` | `Invoke-CompanyPlaceManagement -Action Create -DisplayName 'HQ' -Type Building -City Seattle` |
| `Submit-SystemInfoTicket` | `Submit-SystemInfoTicket.ps1` | `SiteName`, `RequesterEmail`, `[Subject]`, `[Description]`, `[LibraryName]`, `[FolderPath]` | `Submit-SystemInfoTicket -SiteName IT -RequesterEmail 'user@contoso.com'` |
| `New-SPUsageReport` | `Generate-SPUsageReport.ps1` | `[ItemThreshold]`, `[RequesterEmail]`, `[CsvPath]`, `[TranscriptPath]` | `New-SPUsageReport -RequesterEmail 'user@contoso.com'` |
| `Install-MaintenanceTasks` | `Setup-ScheduledMaintenance.ps1` | `[Register]` | `Install-MaintenanceTasks -Register` |
| `Sync-SupportTools` | *git* | `[RepositoryUrl]`, `[InstallPath]` | `Sync-SupportTools` |
| `Invoke-RemoteAudit` | *built-in* | `ComputerName` | `Invoke-RemoteAudit -ComputerName PC1` |

For details on what each script does see [scripts/README.md](../scripts/README.md).

