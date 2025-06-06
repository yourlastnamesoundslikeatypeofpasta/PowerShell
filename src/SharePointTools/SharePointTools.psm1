# SharePoint cleanup helpers

# Load configuration values if available
$repoRoot = Split-Path -Path $PSScriptRoot -Parent | Split-Path -Parent
$settingsFile = Join-Path $repoRoot 'config/SharePointToolsSettings.psd1'
$SharePointToolsSettings = @{ ClientId=''; TenantId=''; CertPath=''; Sites=@{} }
if (Test-Path $settingsFile) {
    try { $SharePointToolsSettings = Import-PowerShellDataFile $settingsFile } catch {}
}

$loggingModule = Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath 'Logging/Logging.psd1'
Import-Module $loggingModule -ErrorAction SilentlyContinue

# Override configuration with environment variables when provided
if ($env:SPTOOLS_CLIENT_ID) { $SharePointToolsSettings.ClientId = $env:SPTOOLS_CLIENT_ID }
if ($env:SPTOOLS_TENANT_ID) { $SharePointToolsSettings.TenantId = $env:SPTOOLS_TENANT_ID }
if ($env:SPTOOLS_CERT_PATH) { $SharePointToolsSettings.CertPath = $env:SPTOOLS_CERT_PATH }

# Load required module once at module scope
try {
    Import-Module PnP.PowerShell -ErrorAction Stop
} catch {
    Write-Warning 'PnP.PowerShell module not found. SharePoint functions may not work until it is installed.'
}

function Write-SPToolsHacker {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Green -BackgroundColor Black
    Write-STLog $Message
}

function Save-SPToolsSettings {
    <#
    .SYNOPSIS
        Persists SharePoint Tools configuration to disk.
    #>
    Write-SPToolsHacker '>>> SAVING CONFIGURATION'
    $SharePointToolsSettings | Out-File -FilePath $settingsFile -Encoding utf8
    Write-SPToolsHacker '>>> CONFIGURATION SAVED'
}

function Get-SPToolsSettings {
    <#
    .SYNOPSIS
        Retrieves the current SharePoint Tools settings.
    #>
    Write-SPToolsHacker '>>> RETRIEVING SETTINGS'
    $SharePointToolsSettings
}

function Get-SPToolsSiteUrl {
    <#
    .SYNOPSIS
        Gets the site URL mapped to a given name.
    .PARAMETER SiteName
        Friendly name of the site.
    #>
    param([Parameter(Mandatory)][string]$SiteName)
    Write-SPToolsHacker ">>> LOOKING UP $SiteName"
    $url = $SharePointToolsSettings.Sites[$SiteName]
    if (-not $url) { throw "Site '$SiteName' not found in settings." }
    Write-SPToolsHacker ">>> URL FOUND: $url"
    $url
}

function Add-SPToolsSite {
    <#
    .SYNOPSIS
        Adds a new SharePoint site entry to the settings file.
    .PARAMETER Name
        Key used to reference the site.
    .PARAMETER Url
        Full URL of the SharePoint site.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$Url
    )
    Write-SPToolsHacker ">>> ADDING SITE $Name"
    $SharePointToolsSettings.Sites[$Name] = $Url
    Save-SPToolsSettings
    Write-SPToolsHacker ">>> SITE ADDED"
}

function Set-SPToolsSite {
    <#
    .SYNOPSIS
        Updates an existing SharePoint site entry.
    .PARAMETER Name
        Key used to reference the site.
    .PARAMETER Url
        New URL to set for the site.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$Url
    )
    Write-SPToolsHacker ">>> UPDATING SITE $Name"
    $SharePointToolsSettings.Sites[$Name] = $Url
    Save-SPToolsSettings
    Write-SPToolsHacker ">>> SITE UPDATED"
}

function Remove-SPToolsSite {
    <#
    .SYNOPSIS
        Removes a SharePoint site entry from the settings file.
    .PARAMETER Name
        Key of the site to remove.
    #>
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Name)
    Write-SPToolsHacker ">>> REMOVING SITE $Name"
    [void]$SharePointToolsSettings.Sites.Remove($Name)
    Save-SPToolsSettings
    Write-SPToolsHacker ">>> SITE REMOVED"
}


function Invoke-YFArchiveCleanup {
    <#
    .SYNOPSIS
        Removes archive items from the YF site.
    #>
    [CmdletBinding()]
    param()

    Invoke-ArchiveCleanup -SiteName 'YF'
}

function Invoke-IBCCentralFilesArchiveCleanup {
    <#
    .SYNOPSIS
        Removes archive items from the IBCCentralFiles site.
    #>
    [CmdletBinding()]
    param()

    Invoke-ArchiveCleanup -SiteName 'IBCCentralFiles'
}

function Invoke-MexCentralFilesArchiveCleanup {
    <#
    .SYNOPSIS
        Removes archive items from the MexCentralFiles site.
    #>
    [CmdletBinding()]
    param()

    Invoke-ArchiveCleanup -SiteName 'MexCentralFiles'
}

<#
.SYNOPSIS
  Removes archive folders and files from a SharePoint library.
.DESCRIPTION
  Connects using PnP.PowerShell and deletes items matching zzz_Archive.
#>
function Invoke-ArchiveCleanup {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$SiteName,
        [string]$SiteUrl,
        [string]$LibraryName = 'Shared Documents',
        [string]$ClientId = $SharePointToolsSettings.ClientId,
        [string]$TenantId = $SharePointToolsSettings.TenantId,
        [string]$CertPath = $SharePointToolsSettings.CertPath,
        [string]$TranscriptPath
    )

    if (-not $SiteUrl) { $SiteUrl = Get-SPToolsSiteUrl -SiteName $SiteName }

    Connect-PnPOnline -Url $SiteUrl -ClientId $ClientId -Tenant $TenantId -CertificatePath $CertPath

    if (-not $TranscriptPath) {
        $TranscriptPath = "$env:USERPROFILE/SHAREPOINT_CLEANUP_${SiteName}_$(Get-Date -Format yyyyMMdd_HHmmss).log"
    }
    Start-Transcript -Path $TranscriptPath -Append

    Write-Verbose "[+] Scanning target: $SiteName"
    $items = Get-PnPListItem -List $LibraryName -PageSize 5000

    $files   = $items | Where-Object { $_.FileSystemObjectType -eq 'File' }
    $folders = $items | Where-Object { $_.FileSystemObjectType -eq 'Folder' }

    $archivedFiles = $files | Where-Object { $_.FieldValues.FileRef -match 'zzz_Archive' }
    $archivedFolders = $folders | Where-Object { $_.FieldValues.FileRef -match 'zzz_Archive' }

    $filesDeleted = 0
    $foldersDeleted = 0

    Write-Verbose "[>] Located $($archivedFiles.Count) archived files marked for deletion."
    foreach ($file in $archivedFiles) {
        $filePath = $file.FieldValues.FileRef
        try {
            Write-Verbose "-- Deleting file: $filePath"
            Remove-PnPFile -ServerRelativeUrl $filePath -Force -ErrorAction Stop
            $filesDeleted++
        } catch {
            Write-Warning "[!] FILE DELETE FAIL: $filePath :: $_"
        }
    }

    $archivedFoldersSorted = $archivedFolders | Sort-Object {
        ($_.FieldValues.FileRef -split '/').Count
    } -Descending

    Write-Verbose "[>] Initiating folder cleanup (leaf-first)"
    foreach ($folder in $archivedFoldersSorted) {
        $folderPath = $folder.FieldValues.FileDirRef
        $folderName = $folder.FieldValues.FileLeafRef
        $fullPath = "$folderPath/$folderName"

        $relativePath = $fullPath -replace '^.*?Shared Documents/?', ''
        $folderDepth = ($relativePath -split '/').Count
        if ($folderDepth -le 1) {
            Write-Host "-- Skipping root-level folder: $fullPath" -ForegroundColor DarkYellow
            continue
        }

        try {
            Write-Verbose "-- Deleting folder: $fullPath"
            Remove-PnPFolder -Name $folderName -Folder $folderPath -Force -ErrorAction Stop
            $foldersDeleted++
        } catch {
            Write-Warning "[!] FOLDER DELETE FAIL: $fullPath :: $_"
        }
    }

    Stop-Transcript

    [pscustomobject]@{
        SiteName           = $SiteName
        ItemsScanned       = $items.Count
        ArchivedFilesFound = $archivedFiles.Count
        ArchivedFoldersFound = $archivedFolders.Count
        FilesDeleted       = $filesDeleted
        FoldersDeleted     = $foldersDeleted
        LogPath            = $TranscriptPath
    }
}

function Invoke-YFFileVersionCleanup {
    <#
    .SYNOPSIS
        Removes old file versions from the YF site.
    #>
    [CmdletBinding()]
    param()

    Invoke-FileVersionCleanup -SiteName 'YF'
}

function Invoke-IBCCentralFilesFileVersionCleanup {
    <#
    .SYNOPSIS
        Removes old file versions from the IBCCentralFiles site.
    #>
    [CmdletBinding()]
    param()

    Invoke-FileVersionCleanup -SiteName 'IBCCentralFiles'
}

function Invoke-MexCentralFilesFileVersionCleanup {
    <#
    .SYNOPSIS
        Removes old file versions from the MexCentralFiles site.
    #>
    [CmdletBinding()]
    param()

    Invoke-FileVersionCleanup -SiteName 'MexCentralFiles'
}

<#
.SYNOPSIS
  Reports files with multiple versions.
.DESCRIPTION
  Generates a CSV of files with more than one version.
#>
function Invoke-FileVersionCleanup {
    [CmdletBinding()]
    param(
        [string]$SiteName,
        [string]$SiteUrl,
        [string]$LibraryName = 'Shared Documents',
        [string]$ClientId = $SharePointToolsSettings.ClientId,
        [string]$TenantId = $SharePointToolsSettings.TenantId,
        [string]$CertPath = $SharePointToolsSettings.CertPath,
        [string]$ReportPath = 'exportedReport.csv'
    )

    if (-not $SiteUrl) { $SiteUrl = Get-SPToolsSiteUrl -SiteName $SiteName }

    Connect-PnPOnline -Url $SiteUrl -ClientId $ClientId -Tenant $TenantId -CertificatePath $CertPath

    $rootFolder = Get-PnPFolder -ListRootFolder $LibraryName
    $subFolders = $rootFolder | Get-PnPFolderInFolder
    $targetFolder = $subFolders | Where-Object { $_.Name -eq 'Marketing' }

    Write-Host "[+] Scanning target: $SiteName"
    $items = $targetFolder | Get-PnPFolderItem -Recursive -Verbose
    Write-Host "[>] Located $($items.Count) files within $SiteUrl"

    $files = $items | Where-Object { $_.GetType().Name -eq 'File' }

    $report = foreach ($file in $files) {
        $versions = Get-PnPProperty -ClientObject $file -Property Versions
        if ($versions.Count -gt 1) {
            [pscustomobject]@{
                Name              = $file.Name
                Path              = $file.ServerRelativePath
                TotalVersionCount = $versions.Count
                TotalVersionBytes = [math]::Round((($versions.Size | Measure-Object -Sum).Sum) / 1GB, 8)
                TrueFileSize      = [math]::Round($file.Length / 1GB, 8)
            }
        }
    }

    $report | Export-Csv $ReportPath -NoTypeInformation
    Write-Host "[✓] Report exported to $ReportPath" -ForegroundColor Green
}

<#
.SYNOPSIS
  Removes sharing links from a SharePoint library.
.DESCRIPTION
  Recursively scans a folder and deletes all file and folder sharing links.
#>
function Invoke-SharingLinkCleanup {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$SiteName,
        [string]$SiteUrl,
        [string]$LibraryName = 'Shared Documents',
        [string]$FolderName,
        [string]$ClientId = $SharePointToolsSettings.ClientId,
        [string]$TenantId = $SharePointToolsSettings.TenantId,
        [string]$CertPath = $SharePointToolsSettings.CertPath,
        [string]$TranscriptPath
    )

    if (-not $SiteUrl) { $SiteUrl = Get-SPToolsSiteUrl -SiteName $SiteName }

    Connect-PnPOnline -Url $SiteUrl -ClientId $ClientId -Tenant $TenantId -CertificatePath $CertPath

    if (-not $TranscriptPath) {
        $TranscriptPath = "$env:USERPROFILE/SHAREPOINT_LINK_CLEANUP_${SiteName}_$(Get-Date -Format yyyyMMdd_HHmmss).log"
    }
    Start-Transcript -Path $TranscriptPath -Append

    $root = Get-PnPFolder -ListRootFolder $LibraryName
    $folders = $root | Get-PnPFolderInFolder

    if (-not $FolderName) {
        $selectionMap = @{}
        $i = 0
        foreach ($f in $folders) {
            Write-Host "$i - $($f.Name)"
            $selectionMap[$i] = $f
            $i++
        }
        $choice = Read-Host -Prompt 'Select folder number'
        $targetFolder = $selectionMap[$choice]
        if (-not $targetFolder) { throw 'Invalid folder selection.' }
    } else {
        $targetFolder = $folders | Where-Object Name -eq $FolderName
        if (-not $targetFolder) { throw "Folder '$FolderName' not found." }
    }

    Write-Host "[>] Scanning $($targetFolder.Name) for sharing links..." -ForegroundColor Cyan
    $items = $targetFolder | Get-PnPFolderItem -Recursive
    $removed = [System.Collections.Generic.List[string]]::new()

    foreach ($item in $items) {
        try {
            $link = (Get-PnPFileSharingLink -FileUrl $item.ServerRelativeUrl -ErrorAction Stop).Link.WebUrl
            if ($link) {
                Remove-PnPFileSharingLink -FileUrl $item.ServerRelativeUrl -Force -ErrorAction SilentlyContinue
                $removed.Add($item.ServerRelativeUrl)
                Write-Warning "Removed file link: $($item.ServerRelativeUrl)"
            }
        } catch {
            try {
                $folderLink = (Get-PnPFolderSharingLink -Folder $item.ServerRelativeUrl -ErrorAction Stop).Link.WebUrl
                if ($folderLink) {
                    Remove-PnPFolderSharingLink -Folder $item.ServerRelativeUrl -Force -ErrorAction SilentlyContinue
                    $removed.Add($item.ServerRelativeUrl)
                    Write-Warning "Removed folder link: $($item.ServerRelativeUrl)"
                }
            } catch {
                # ignore if no links exist
            }
        }
    }

    if ($removed.Count) {
        Write-Warning "Sharing links removed from the following items:" 
        $removed | Write-Warning
    } else {
        Write-Host '[✓] No sharing links found.' -ForegroundColor Green
    }

    Stop-Transcript
    Disconnect-PnPOnline
}

function Invoke-YFSharingLinkCleanup {
    <#
    .SYNOPSIS
        Removes sharing links from the YF site.
    #>
    [CmdletBinding()]
    param()

    Invoke-SharingLinkCleanup -SiteName 'YF'
}

function Invoke-IBCCentralFilesSharingLinkCleanup {
    <#
    .SYNOPSIS
        Removes sharing links from the IBCCentralFiles site.
    #>
    [CmdletBinding()]
    param()

    Invoke-SharingLinkCleanup -SiteName 'IBCCentralFiles'
}

function Invoke-MexCentralFilesSharingLinkCleanup {
    <#
    .SYNOPSIS
        Removes sharing links from the MexCentralFiles site.
    #>
    [CmdletBinding()]
    param()

    Invoke-SharingLinkCleanup -SiteName 'MexCentralFiles'
}


function Get-SPToolsLibraryReport {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$SiteName,
        [string]$SiteUrl,
        [string]$ClientId = $SharePointToolsSettings.ClientId,
        [string]$TenantId = $SharePointToolsSettings.TenantId,
        [string]$CertPath = $SharePointToolsSettings.CertPath
    )

    if (-not $SiteUrl) { $SiteUrl = Get-SPToolsSiteUrl -SiteName $SiteName }
    Write-SPToolsHacker ">>> LIBRARY REPORT: $SiteName"

    Connect-PnPOnline -Url $SiteUrl -ClientId $ClientId -Tenant $TenantId -CertificatePath $CertPath

    $lists = Get-PnPList | Where-Object { $_.BaseTemplate -eq 101 }
    $report = foreach ($list in $lists) {
        [pscustomobject]@{
            SiteName     = $SiteName
            LibraryName  = $list.Title
            ItemCount    = $list.ItemCount
            LastModified = $list.LastItemUserModifiedDate
        }
    }

    Disconnect-PnPOnline
    Write-SPToolsHacker '>>> REPORT COMPLETE'
    $report
}

function Get-SPToolsAllLibraryReports {
    [CmdletBinding()]
    param()

    Write-SPToolsHacker '>>> GENERATING ALL LIBRARY REPORTS'

    foreach ($entry in $SharePointToolsSettings.Sites.GetEnumerator()) {
        Get-SPToolsLibraryReport -SiteName $entry.Key -SiteUrl $entry.Value
    }
    Write-SPToolsHacker '>>> REPORTS COMPLETE'
}

function Get-SPToolsRecycleBinReport {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$SiteName,
        [string]$SiteUrl,
        [string]$ClientId = $SharePointToolsSettings.ClientId,
        [string]$TenantId = $SharePointToolsSettings.TenantId,
        [string]$CertPath = $SharePointToolsSettings.CertPath
    )

    if (-not $SiteUrl) { $SiteUrl = Get-SPToolsSiteUrl -SiteName $SiteName }
    Write-SPToolsHacker ">>> RECYCLE BIN REPORT: $SiteName"

    Connect-PnPOnline -Url $SiteUrl -ClientId $ClientId -Tenant $TenantId -CertificatePath $CertPath

    $items = Get-PnPRecycleBinItem
    $totalSize = ($items | Measure-Object -Property Size -Sum).Sum
    $report = [pscustomobject]@{
        SiteName    = $SiteName
        ItemCount   = $items.Count
        TotalSizeMB = [math]::Round($totalSize / 1MB, 2)
    }

    Disconnect-PnPOnline
    Write-SPToolsHacker '>>> REPORT COMPLETE'
    $report
}

function Clear-SPToolsRecycleBin {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$SiteName,
        [string]$SiteUrl,
        [switch]$SecondStage,
        [string]$ClientId = $SharePointToolsSettings.ClientId,
        [string]$TenantId = $SharePointToolsSettings.TenantId,
        [string]$CertPath = $SharePointToolsSettings.CertPath
    )

    if (-not $SiteUrl) { $SiteUrl = Get-SPToolsSiteUrl -SiteName $SiteName }
    Write-SPToolsHacker ">>> CLEARING RECYCLE BIN: $SiteName"

    Connect-PnPOnline -Url $SiteUrl -ClientId $ClientId -Tenant $TenantId -CertificatePath $CertPath

    if ($SecondStage) {
        Clear-PnPRecycleBinItem -SecondStage -Force
    } else {
        Clear-PnPRecycleBinItem -FirstStage -Force
    }

    Disconnect-PnPOnline
    Write-SPToolsHacker '>>> RECYCLE BIN CLEARED'
}

function Get-SPToolsAllRecycleBinReports {
    [CmdletBinding()]
    param()
    Write-SPToolsHacker '>>> GENERATING ALL RECYCLE BIN REPORTS'
    foreach ($entry in $SharePointToolsSettings.Sites.GetEnumerator()) {
        Get-SPToolsRecycleBinReport -SiteName $entry.Key -SiteUrl $entry.Value
    }
    Write-SPToolsHacker '>>> REPORTS COMPLETE'
}

function Get-SPToolsPreservationHoldReport {
    <#
    .SYNOPSIS
        Reports the size of the Preservation Hold Library.
    .NOTES
        Uses PnP.PowerShell commands. See https://pnp.github.io/powershell/ for details.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$SiteName,
        [string]$SiteUrl,
        [string]$ClientId = $SharePointToolsSettings.ClientId,
        [string]$TenantId = $SharePointToolsSettings.TenantId,
        [string]$CertPath = $SharePointToolsSettings.CertPath
    )

    if (-not $SiteUrl) { $SiteUrl = Get-SPToolsSiteUrl -SiteName $SiteName }
    Write-SPToolsHacker ">>> HOLD REPORT: $SiteName"

    Connect-PnPOnline -Url $SiteUrl -ClientId $ClientId -Tenant $TenantId -CertificatePath $CertPath

    $items = Get-PnPListItem -List 'Preservation Hold Library' -PageSize 2000
    $files = foreach ($item in $items) { Get-PnPProperty -ClientObject $item -Property File }
    $totalSize = ($files | Measure-Object -Property Length -Sum).Sum
    $report = [pscustomobject]@{
        SiteName    = $SiteName
        ItemCount   = $files.Count
        TotalSizeMB = [math]::Round($totalSize / 1MB, 2)
    }

    Disconnect-PnPOnline
    Write-SPToolsHacker '>>> REPORT COMPLETE'
    $report
}

function Get-SPToolsAllPreservationHoldReports {
    [CmdletBinding()]
    param()
    Write-SPToolsHacker '>>> GENERATING ALL HOLD REPORTS'
    foreach ($entry in $SharePointToolsSettings.Sites.GetEnumerator()) {
        Get-SPToolsPreservationHoldReport -SiteName $entry.Key -SiteUrl $entry.Value
    }
    Write-SPToolsHacker '>>> REPORTS COMPLETE'
}
function Get-SPPermissionsReport {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$SiteUrl,
        [string]$FolderUrl,
        [string]$ClientId = $SharePointToolsSettings.ClientId,
        [string]$TenantId = $SharePointToolsSettings.TenantId,
        [string]$CertPath = $SharePointToolsSettings.CertPath
    )

    Write-SPToolsHacker ">>> PERMISSIONS REPORT: $SiteUrl"
    Connect-PnPOnline -Url $SiteUrl -ClientId $ClientId -Tenant $TenantId -CertificatePath $CertPath

    if ($FolderUrl) {
        $target = Get-PnPFolder -Url $FolderUrl
    } else {
        $target = Get-PnPSite
    }

    $assignments = Get-PnPProperty -ClientObject $target -Property RoleAssignments
    $report = foreach ($assignment in $assignments) {
        $member = Get-PnPProperty -ClientObject $assignment -Property Member
        $roles = Get-PnPProperty -ClientObject $assignment -Property RoleDefinitionBindings | ForEach-Object { $_.Name } -join ','
        [pscustomobject]@{
            Member = $member.Title
            Type   = $member.PrincipalType
            Roles  = $roles
        }
    }

    Disconnect-PnPOnline
    Write-SPToolsHacker '>>> REPORT COMPLETE'
    $report
}

function Clean-SPVersionHistory {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$SiteUrl,
        [string]$LibraryName = 'Shared Documents',
        [int]$KeepVersions = 5,
        [string]$ClientId = $SharePointToolsSettings.ClientId,
        [string]$TenantId = $SharePointToolsSettings.TenantId,
        [string]$CertPath = $SharePointToolsSettings.CertPath
    )

    Write-SPToolsHacker ">>> CLEANING VERSIONS ON $SiteUrl"
    Connect-PnPOnline -Url $SiteUrl -ClientId $ClientId -Tenant $TenantId -CertificatePath $CertPath

    $items = Get-PnPListItem -List $LibraryName -PageSize 2000
    foreach ($item in $items) {
        $versions = Get-PnPProperty -ClientObject $item -Property Versions
        if ($versions.Count -gt $KeepVersions) {
            $excess = $versions | Sort-Object -Property Created -Descending | Select-Object -Skip $KeepVersions
            foreach ($v in $excess) { $v.DeleteObject() | Out-Null }
            Invoke-PnPQuery
        }
    }
    Disconnect-PnPOnline
    Write-SPToolsHacker '>>> CLEANUP COMPLETE'
}

function Find-OrphanedSPFiles {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$SiteUrl,
        [string]$LibraryName = 'Shared Documents',
        [int]$Days = 90,
        [string]$ClientId = $SharePointToolsSettings.ClientId,
        [string]$TenantId = $SharePointToolsSettings.TenantId,
        [string]$CertPath = $SharePointToolsSettings.CertPath
    )

    Write-SPToolsHacker ">>> SEARCHING ORPHANED FILES ON $SiteUrl"
    Connect-PnPOnline -Url $SiteUrl -ClientId $ClientId -Tenant $TenantId -CertificatePath $CertPath

    $cutoff = (Get-Date).AddDays(-$Days)
    $items = Get-PnPListItem -List $LibraryName -PageSize 2000
    $report = foreach ($item in $items) {
        $file = Get-PnPProperty -ClientObject $item -Property File
        if ($file.TimeLastModified -lt $cutoff) {
            [pscustomobject]@{
                Name         = $file.Name
                Path         = $file.ServerRelativeUrl
                LastModified = $file.TimeLastModified
            }
        }
    }
    Disconnect-PnPOnline
    Write-SPToolsHacker '>>> SEARCH COMPLETE'
    $report
}

function List-OneDriveUsage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$AdminUrl,
        [string]$ClientId = $SharePointToolsSettings.ClientId,
        [string]$TenantId = $SharePointToolsSettings.TenantId,
        [string]$CertPath = $SharePointToolsSettings.CertPath
    )

    Write-SPToolsHacker '>>> GATHERING ONEDRIVE USAGE'
    Connect-PnPOnline -Url $AdminUrl -ClientId $ClientId -Tenant $TenantId -CertificatePath $CertPath

    $sites = Get-PnPTenantSite -IncludeOneDriveSites
    $report = foreach ($s in $sites) {
        if ($s.Template -eq 'SPSPERS') {
            [pscustomobject]@{
                Url       = $s.Url
                Owner     = $s.Owner
                StorageGB = [math]::Round($s.StorageUsageCurrent / 1GB, 2)
            }
        }
    }

    Disconnect-PnPOnline
    Write-SPToolsHacker '>>> REPORT COMPLETE'
    $report
}
Export-ModuleMember -Function 'Invoke-YFArchiveCleanup','Invoke-IBCCentralFilesArchiveCleanup','Invoke-MexCentralFilesArchiveCleanup','Invoke-ArchiveCleanup','Invoke-YFFileVersionCleanup','Invoke-IBCCentralFilesFileVersionCleanup','Invoke-MexCentralFilesFileVersionCleanup','Invoke-FileVersionCleanup','Invoke-SharingLinkCleanup','Invoke-YFSharingLinkCleanup','Invoke-IBCCentralFilesSharingLinkCleanup','Invoke-MexCentralFilesSharingLinkCleanup','Get-SPToolsSettings','Get-SPToolsSiteUrl','Add-SPToolsSite','Set-SPToolsSite','Remove-SPToolsSite','Get-SPToolsLibraryReport','Get-SPToolsAllLibraryReports','Get-SPToolsRecycleBinReport','Clear-SPToolsRecycleBin','Get-SPToolsAllRecycleBinReports','Get-SPToolsPreservationHoldReport','Get-SPToolsAllPreservationHoldReports','Get-SPPermissionsReport','Clean-SPVersionHistory','Find-OrphanedSPFiles','List-OneDriveUsage' -Variable 'SharePointToolsSettings'

function Show-SharePointToolsBanner {
    $lines = @(
        '=======================================',
        '=   SHAREPOINTTOOLS MODULE ENGAGED    =',
        '=======================================')
    foreach ($line in $lines) {
        Write-Host $line -ForegroundColor Black -BackgroundColor Yellow
    }
    Write-Host ">> Welcome operator. Run 'Get-Command -Module SharePointTools' to view available tools." -ForegroundColor Yellow -BackgroundColor Black
}

Show-SharePointToolsBanner
