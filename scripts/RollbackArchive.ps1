<#+
.SYNOPSIS
    Restores files and folders deleted by CleanupArchive.ps1.
.DESCRIPTION
    Reads a snapshot JSON file created during archive cleanup and
    restores each item from the SharePoint recycle bin.
.PARAMETER SiteUrl
    URL of the SharePoint site.
.PARAMETER SnapshotPath
    Path to the snapshot JSON created by CleanupArchive.ps1.
.EXAMPLE
    ./RollbackArchive.ps1 -SiteUrl "https://contoso.sharepoint.com/sites/Files" -SnapshotPath preDeleteLog.json
#>
param(
    [Parameter(Mandatory)]
    [string]$SiteUrl,
    [string]$SnapshotPath = (Join-Path $PSScriptRoot 'preDeleteLog.json')
)

Import-Module Pnp.PowerShell
$InformationPreference = 'Continue'

Connect-PnPOnline -Url $SiteUrl -Interactive

if (-not (Test-Path $SnapshotPath)) {
    Write-Error "Snapshot file not found: $SnapshotPath"
    return
}

$data = Get-Content -Path $SnapshotPath | ConvertFrom-Json
foreach ($item in $data) {
    if ($item.RecycleBinItemId) {
        try {
            Restore-PnPRecycleBinItem -Identity $item.RecycleBinItemId -Force
            Write-STStatus "Restored $($item.ServerRelativeUrl)" -Level INFO
        }
        catch {
            Write-STStatus "Failed to restore $($item.ServerRelativeUrl): $($_.Exception.Message)" -Level WARN
        }
    }
    else {
        Write-STStatus "No recycle bin id for $($item.ServerRelativeUrl)" -Level WARN
    }
}
