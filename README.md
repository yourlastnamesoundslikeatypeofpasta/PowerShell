# SupportTools PowerShell Module

This repository now packages the collection of scripts as a PowerShell module. The module wraps each script so they can be invoked as standard commands.

## Usage

1. Import the module from the `src/SupportTools` folder:
   ```powershell
   Import-Module ./src/SupportTools/SupportTools.psd1
   ```
2. Run any of the available commands, for example:
   ```powershell
   Get-CommonSystemInfo
   ```

For a list of the wrapped scripts and their descriptions see [scripts/README.md](scripts/README.md).

Additional functions for cleaning up SharePoint archives have been added. Use
`Invoke-ArchiveCleanup` and related helper commands to purge `zzz_Archive`
folders from specific sites.

`Invoke-FileVersionCleanup` now generates a CSV report of files that contain
multiple versions so large libraries can be reviewed.

The command `Invoke-ExchangeCalendarManager` offers an interactive menu for
managing Exchange Online calendar permissions and removing meetings.

`Invoke-SharingLinkCleanup` removes existing sharing links from items within a
document library. Wrapper commands such as `Invoke-YFSharingLinkCleanup` run the
cleanup against predefined sites.
