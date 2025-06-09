# ConfigManagementTools Module

Import the module using its manifest:

```powershell
Import-Module ./src/ConfigManagementTools/ConfigManagementTools.psd1
```

Logs are written to `%USERPROFILE%\SupportToolsLogs\supporttools.log` by default. Override with `$env:ST_LOG_PATH`. Set `ST_LOG_STRUCTURED=1` for JSON output; see [Logging/RichLogFormat.md](Logging/RichLogFormat.md).

## Available Commands

| Command | Description | Example |
|---------|-------------|---------|
| `Add-UserToGroup` | Add users from a CSV to a Microsoft 365 group. | `Add-UserToGroup -CsvPath users.csv -GroupName Team` |
| `Invoke-GroupMembershipCleanup` | Remove users from a group based on a CSV file. | `Invoke-GroupMembershipCleanup -CsvPath remove.csv -GroupName Team` |
| `Install-Font` | Install font files on the system. | `Install-Font -Source C:\Fonts` |
| `Install-MaintenanceTasks` | Register scheduled maintenance tasks. | `Install-MaintenanceTasks -Register` |
| `Invoke-CompanyPlaceManagement` | Manage Microsoft Places locations. | `Invoke-CompanyPlaceManagement -Action Get -DisplayName HQ` |
| `Out-CompanyPlace` | Display place objects in a table. | `Invoke-CompanyPlaceManagement -Action Get -DisplayName HQ | Out-CompanyPlace` |
| `Invoke-DeploymentTemplate` | Run the deployment template script. | `Invoke-DeploymentTemplate -Verbose` |
| `Invoke-ExchangeCalendarManager` | Manage shared calendars in Exchange Online. | `Invoke-ExchangeCalendarManager` |
| `Invoke-PostInstall` | Execute post installation configuration. | `Invoke-PostInstall -Domain contoso.com` |
| `Set-ComputerIPAddress` | Configure IP addresses from a CSV. | `Set-ComputerIPAddress -CsvPath ip.csv` |
| `Set-NetAdapterMetering` | Configure network adapter metering mode. | `Set-NetAdapterMetering -AdapterName Ethernet0` |
| `Set-SharedMailboxAutoReply` | Configure automatic replies on a mailbox. | `Set-SharedMailboxAutoReply -MailboxIdentity help@contoso.com -StartTime (Get-Date) -EndTime (Get-Date).AddDays(7) -InternalMessage 'OOO' -AdminUser admin@contoso.com` |
| `Set-TimeZoneEasternStandardTime` | Set the system time zone to Eastern Standard Time. | `Set-TimeZoneEasternStandardTime` |
| `Test-Drift` | Compare system configuration against a baseline file. | `Test-Drift -BaselinePath baseline.json` |
