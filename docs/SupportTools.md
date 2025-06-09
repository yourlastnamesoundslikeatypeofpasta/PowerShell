# SupportTools Module

This module exposes helper commands that wrap the scripts located in the `scripts` folder. Import the module and run the desired function rather than calling the script directly.

```powershell
Import-Module ./src/SupportTools/SupportTools.psd1
```

For a guided experience, run `./scripts/SupportToolsMenu.ps1` with the optional `-UserRole` parameter to select common tasks from an interactive menu tailored for `Helpdesk` or `Site Admin` roles. To browse and execute any script in the repository, use `./scripts/ScriptLauncher.ps1` for a general menu of options.

### Simulation Mode

All commands now accept a `-Simulate` switch. When used, the command logs each step and returns randomized mock data without making changes. This is useful for testing in lab environments.

### Learning Mode

Use the `-Explain` switch with any command to view the underlying script's full help content instead of executing it. This is useful when training new administrators on what each task does.

### Transcripts and Error Records

Most commands now accept `-TranscriptPath` to record a transcript. If a command fails, it returns a standard `ErrorRecord` containing the exception details.

```powershell
$result = Sync-SupportTools -RepositoryUrl 'bad' -InstallPath 'C:\temp'
if ($result -is [System.Management.Automation.ErrorRecord]) {
    $result.Exception.Message
}
```

### Logging

Commands record their activity to `%USERPROFILE%\SupportToolsLogs\supporttools.log` by default or to `$env:ST_LOG_PATH` if set.
Use `-Structured` or set `ST_LOG_STRUCTURED=1` to output JSON events. See [../Logging/RichLogFormat.md](../Logging/RichLogFormat.md) for an example of the structure.

## Available Commands

The table below lists each command and the script it invokes. Arguments not listed are forwarded to the underlying script unchanged.

| Command | Wrapped Script | Key Parameters | Example |
|---------|----------------|---------------|---------|
| `Clear-ArchiveFolder` | `CleanupArchive.ps1` | *passthrough* | `Clear-ArchiveFolder -SiteUrl https://contoso.sharepoint.com/sites/Files` |
| `Restore-ArchiveFolder` | `RollbackArchive.ps1` | `SnapshotPath`, `SiteUrl` | `Restore-ArchiveFolder -SiteUrl https://contoso.sharepoint.com/sites/Files -SnapshotPath preDeleteLog.json` |
| `Clear-TempFile` | `CleanupTempFiles.ps1` | *passthrough* | `Clear-TempFile` |
| `Convert-ExcelToCsv` | `Convert-ExcelToCsv.ps1` | *passthrough* | `Convert-ExcelToCsv -Path workbook.xlsx` |
| `Export-ProductKey` | `ProductKey.ps1` | *passthrough* | `Export-ProductKey` |
| `Get-UniquePermission` | `Get-UniquePermissions.ps1` | *passthrough* | `Get-UniquePermission -SiteUrl https://contoso.sharepoint.com/sites/HR` |
| `Invoke-JobBundle` | `Run-JobBundle.ps1` | `Path`, `LogArchivePath` | `Invoke-JobBundle -Path bundle.job.zip -LogArchivePath out.zip` |
| `Invoke-PerformanceAudit` | `Invoke-PerformanceAudit.ps1` | *passthrough* | `Invoke-PerformanceAudit` |
| `Search-ReadMe` | `Search-ReadMe.ps1` | *passthrough* | `Search-ReadMe -Pattern 'setup'` |
| `Start-Countdown` | `SimpleCountdown.ps1` | *passthrough* | `Start-Countdown -Seconds 30` |
| `Sync-SupportTools` | *git* | `[RepositoryUrl]`, `[InstallPath]` | `Sync-SupportTools` |
| `New-SPUsageReport` | `Generate-SPUsageReport.ps1` | `[ItemThreshold]`, `[RequesterEmail]`, `[CsvPath]`, `[TranscriptPath]` | `New-SPUsageReport -RequesterEmail 'user@contoso.com'` |
| `Invoke-NewHireUserAutomation` | `Create-NewHireUser.ps1` | `[PollMinutes]`, `[-Once]` | `Invoke-NewHireUserAutomation -Once` |
| `New-STDashboard` | *built-in* | `[LogPath]`, `[TelemetryLogPath]`, `[OutputPath]`, `[LogLines]` | `New-STDashboard` |
