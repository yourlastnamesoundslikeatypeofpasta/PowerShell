# SharePointTools Module

This module provides SharePoint cleanup and reporting utilities. Import the module using its manifest:

```powershell
Import-Module ./src/SharePointTools/SharePointTools.psd1
```

Validate prerequisites using `Test-SPToolsPrereqs`:

```powershell
Test-SPToolsPrereqs -Install
```

Before running any command ensure the settings file has been configured using `./scripts/Configure-SharePointTools.ps1` (parameters can be passed for unattended use) or by setting the environment variables `SPTOOLS_CLIENT_ID`, `SPTOOLS_TENANT_ID` and `SPTOOLS_CERT_PATH`.

All functions emit short, high contrast messages following the style in [ModuleStyleGuide.md](ModuleStyleGuide.md).

## Available Commands

| Command | Description | Key Parameters | Example |
|---------|-------------|---------------|---------|
| `Save-SPToolsSettings` | Persist the current configuration to disk. | `[Path]` | `Save-SPToolsSettings -Path ./mysettings.psd1` |
| `Get-SPToolsSettings` | Return the loaded configuration. | none | `Get-SPToolsSettings` |
| `Test-SPToolsPrereqs` | Verify PnP.PowerShell dependency. Use `-Install` to install. | `[Install]` | `Test-SPToolsPrereqs -Install` |
| `Get-SPToolsSiteUrl` | Retrieve a site URL by friendly name. | `SiteName` | `Get-SPToolsSiteUrl -SiteName HR` |
| `Add-SPToolsSite` | Add a SharePoint site entry. | `Name`, `Url` | `Add-SPToolsSite -Name HR -Url https://contoso.sharepoint.com/sites/hr` |
| `Set-SPToolsSite` | Update an existing site entry. | `Name`, `Url` | `Set-SPToolsSite -Name HR -Url https://contoso.sharepoint.com/sites/hr2` |
| `Remove-SPToolsSite` | Remove a site entry. | `Name` | `Remove-SPToolsSite -Name HR` |
| `Invoke-YFArchiveCleanup` | Remove archive folders from the YF site. | none | `Invoke-YFArchiveCleanup -Verbose` |
| `Invoke-IBCCentralFilesArchiveCleanup` | Remove archive folders from the IBCCentralFiles site. | none | `Invoke-IBCCentralFilesArchiveCleanup` |
| `Invoke-MexCentralFilesArchiveCleanup` | Remove archive folders from the MexCentralFiles site. | none | `Invoke-MexCentralFilesArchiveCleanup` |
| `Invoke-ArchiveCleanup` | Delete `zzz_Archive_Production` folders from a library. | `SiteName`, `[SiteUrl]`, `[LibraryName]`, `[ClientId]`, `[TenantId]`, `[CertPath]` | `Invoke-ArchiveCleanup -SiteName HR -LibraryName Documents` |
| `Invoke-YFFileVersionCleanup` | Remove old file versions from the YF site. | none | `Invoke-YFFileVersionCleanup` |
| `Invoke-IBCCentralFilesFileVersionCleanup` | Remove old file versions from the IBCCentralFiles site. | none | `Invoke-IBCCentralFilesFileVersionCleanup` |
| `Invoke-MexCentralFilesFileVersionCleanup` | Remove old file versions from the MexCentralFiles site. | none | `Invoke-MexCentralFilesFileVersionCleanup` |
| `Invoke-FileVersionCleanup` | Generate a CSV report of files with multiple versions. | `SiteName`, `[SiteUrl]`, `[LibraryName]`, `[ClientId]`, `[TenantId]`, `[CertPath]`, `[ReportPath]` | `Invoke-FileVersionCleanup -SiteName HR -ReportPath report.csv` |
| `Invoke-SharingLinkCleanup` | Remove sharing links from a library folder. | `SiteName`, `[SiteUrl]`, `[LibraryName]`, `[FolderName]`, `[ClientId]`, `[TenantId]`, `[CertPath]` | `Invoke-SharingLinkCleanup -SiteName HR -FolderName Marketing` |
| `Invoke-YFSharingLinkCleanup` | Remove sharing links from the YF site. | none | `Invoke-YFSharingLinkCleanup` |
| `Invoke-IBCCentralFilesSharingLinkCleanup` | Remove sharing links from the IBCCentralFiles site. | none | `Invoke-IBCCentralFilesSharingLinkCleanup` |
| `Invoke-MexCentralFilesSharingLinkCleanup` | Remove sharing links from the MexCentralFiles site. | none | `Invoke-MexCentralFilesSharingLinkCleanup` |
| `Get-SPToolsLibraryReport` | Report document library counts. | `SiteName`, `[SiteUrl]`, `[ClientId]`, `[TenantId]`, `[CertPath]` | `Get-SPToolsLibraryReport -SiteName HR` |
| `Get-SPToolsAllLibraryReports` | Run `Get-SPToolsLibraryReport` for all configured sites. | none | `Get-SPToolsAllLibraryReports` |
| `Get-SPToolsRecycleBinReport` | Report recycle bin usage. | `SiteName`, `[SiteUrl]`, `[ClientId]`, `[TenantId]`, `[CertPath]` | `Get-SPToolsRecycleBinReport -SiteName HR` |
| `Clear-SPToolsRecycleBin` | Empty the recycle bin for a site. | `SiteName`, `[SiteUrl]`, `[SecondStage]`, `[ClientId]`, `[TenantId]`, `[CertPath]` | `Clear-SPToolsRecycleBin -SiteName HR -SecondStage` |
| `Get-SPToolsAllRecycleBinReports` | Run `Get-SPToolsRecycleBinReport` for all sites. | none | `Get-SPToolsAllRecycleBinReports` |
| `Get-SPToolsPreservationHoldReport` | Report Preservation Hold Library size. | `SiteName`, `[SiteUrl]`, `[ClientId]`, `[TenantId]`, `[CertPath]` | `Get-SPToolsPreservationHoldReport -SiteName HR` |
| `Get-SPToolsAllPreservationHoldReports` | Run `Get-SPToolsPreservationHoldReport` for all sites. | none | `Get-SPToolsAllPreservationHoldReports` |
| `Get-SPPermissionsReport` | List role assignments for a site or folder. | `SiteUrl`, `[FolderUrl]`, `[ClientId]`, `[TenantId]`, `[CertPath]` | `Get-SPPermissionsReport -SiteUrl https://contoso.sharepoint.com/sites/hr` |
| `Clean-SPVersionHistory` | Trim file versions beyond a limit. | `SiteUrl`, `[LibraryName]`, `[KeepVersions]`, `[ClientId]`, `[TenantId]`, `[CertPath]` | `Clean-SPVersionHistory -SiteUrl https://contoso.sharepoint.com/sites/hr -KeepVersions 5` |
| `Find-OrphanedSPFiles` | Locate files not modified for a period. | `SiteUrl`, `[LibraryName]`, `[Days]`, `[ClientId]`, `[TenantId]`, `[CertPath]` | `Find-OrphanedSPFiles -SiteUrl https://contoso.sharepoint.com/sites/hr -Days 90` |
| `Get-SPToolsFileReport` | Export file metadata from a library. | `SiteName`, `[SiteUrl]`, `[LibraryName]`, `[ClientId]`, `[TenantId]`, `[CertPath]`, `[ReportPath]` | `Get-SPToolsFileReport -SiteName HR -ReportPath files.csv` |
| `Select-SPToolsFolder` | Recursively choose a library folder. | `SiteName`, `[SiteUrl]`, `[LibraryName]`, `[Filter]` | `Select-SPToolsFolder -SiteName HR` |
| `List-OneDriveUsage` | Report OneDrive storage use across the tenant. | `AdminUrl`, `[ClientId]`, `[TenantId]`, `[CertPath]` | `List-OneDriveUsage -AdminUrl https://contoso-admin.sharepoint.com` |


## Example Scenarios

The following walkthroughs demonstrate how the commands can be combined.

### 1. Configure a site and generate a library report

```powershell
# Configure authentication and add your first site
./scripts/Configure-SharePointTools.ps1
Add-SPToolsSite -Name HR -Url https://contoso.sharepoint.com/sites/hr

# Run a library usage report
$report = Get-SPToolsLibraryReport -SiteName 'HR'
$report | Out-SPToolsLibraryReport
```

### 2. Clean up archived folders

```powershell
Invoke-ArchiveCleanup -SiteName HR -LibraryName "Shared Documents" -Verbose
```

Archived folders matching `zzz_Archive_Production` will be removed and actions are written to a transcript file.

### 3. Trim old versions and sharing links

```powershell
Invoke-FileVersionCleanup -SiteName HR -ReportPath versions.csv
Invoke-SharingLinkCleanup -SiteName HR -FolderName Marketing
```

The cleanup commands output a CSV of files with excess versions and remove outdated sharing links from the Marketing folder.

### 4. Capture telemetry events

```powershell
$env:ST_ENABLE_TELEMETRY = '1'
# Certificate authentication
Connect-SPToolsOnline -Url https://contoso.sharepoint.com -ClientId $cid -TenantId $tid -CertPath cert.pfx
# Client secret authentication
Connect-SPToolsOnline -Url https://contoso.sharepoint.com -ClientId $cid -TenantId $tid -ClientSecret $secret
# Interactive device login
Connect-SPToolsOnline -Url https://contoso.sharepoint.com -DeviceLogin
$env:ST_ENABLE_TELEMETRY = ''
```

Telemetry records command usage under the user's profile in `SupportToolsTelemetry/telemetry.jsonl`.
