# SharePoint cleanup helpers

# Load configuration values if available
$repoRoot = Split-Path -Path $PSScriptRoot -Parent | Split-Path -Parent
$settingsFile = Join-Path $repoRoot 'config/SharePointToolsSettings.psd1'
$SharePointToolsSettings = @{ ClientId=''; TenantId=''; CertPath='' }
if (Test-Path $settingsFile) {
    try { $SharePointToolsSettings = Import-PowerShellDataFile $settingsFile } catch {}
}


function Invoke-YFArchiveCleanup {
    [CmdletBinding()]
    param()

    Invoke-ArchiveCleanup -SiteName 'YF' -SiteUrl 'https://contoso.sharepoint.com/sites/YF'
}

function Invoke-IBCCentralFilesArchiveCleanup {
    [CmdletBinding()]
    param()

    Invoke-ArchiveCleanup -SiteName 'IBCCentralFiles' -SiteUrl 'https://contoso.sharepoint.com/sites/IBCCentralFiles'
}

function Invoke-MexCentralFilesArchiveCleanup {
    [CmdletBinding()]
    param()

    Invoke-ArchiveCleanup -SiteName 'MexCentralFiles' -SiteUrl 'https://contoso.sharepoint.com/sites/MexCentralFiles'
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
        [Parameter(Mandatory)]
        [string]$SiteUrl,
        [string]$LibraryName = 'Shared Documents',
        [string]$ClientId = $SharePointToolsSettings.ClientId,
        [string]$TenantId = $SharePointToolsSettings.TenantId,
        [string]$CertPath = $SharePointToolsSettings.CertPath
    )

    Import-Module PnP.PowerShell -ErrorAction Stop
    Connect-PnPOnline -Url $SiteUrl -ClientId $ClientId -Tenant $TenantId -CertificatePath $CertPath

    $logPath = "$env:USERPROFILE/SHAREPOINT_CLEANUP_${SiteName}_$(Get-Date -Format yyyyMMdd_HHmmss).log"
    Start-Transcript -Path $logPath -Append

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
        LogPath            = $logPath
    }
}

function Invoke-YFFileVersionCleanup {
    [CmdletBinding()]
    param()

    Invoke-FileVersionCleanup -SiteName 'YF' -SiteUrl 'https://contoso.sharepoint.com/sites/YF'
}

function Invoke-IBCCentralFilesFileVersionCleanup {
    [CmdletBinding()]
    param()

    Invoke-FileVersionCleanup -SiteName 'IBCCentralFiles' -SiteUrl 'https://contoso.sharepoint.com/sites/IBCCentralFiles'
}

function Invoke-MexCentralFilesFileVersionCleanup {
    [CmdletBinding()]
    param()

    Invoke-FileVersionCleanup -SiteName 'MexCentralFiles' -SiteUrl 'https://contoso.sharepoint.com/sites/MexCentralFiles'
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

    Import-Module PnP.PowerShell -ErrorAction Stop
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
        [Parameter(Mandatory)]
        [string]$SiteUrl,
        [string]$LibraryName = 'Shared Documents',
        [string]$FolderName,
        [string]$ClientId = $SharePointToolsSettings.ClientId,
        [string]$TenantId = $SharePointToolsSettings.TenantId,
        [string]$CertPath = $SharePointToolsSettings.CertPath
    )

    Import-Module PnP.PowerShell -ErrorAction Stop
    Connect-PnPOnline -Url $SiteUrl -ClientId $ClientId -Tenant $TenantId -CertificatePath $CertPath

    $logPath = "$env:USERPROFILE/SHAREPOINT_LINK_CLEANUP_${SiteName}_$(Get-Date -Format yyyyMMdd_HHmmss).log"
    Start-Transcript -Path $logPath -Append

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
    [CmdletBinding()]
    param()

    Invoke-SharingLinkCleanup -SiteName 'YF' -SiteUrl 'https://contoso.sharepoint.com/sites/YF'
}

function Invoke-IBCCentralFilesSharingLinkCleanup {
    [CmdletBinding()]
    param()

    Invoke-SharingLinkCleanup -SiteName 'IBCCentralFiles' -SiteUrl 'https://contoso.sharepoint.com/sites/IBCCentralFiles'
}

function Invoke-MexCentralFilesSharingLinkCleanup {
    [CmdletBinding()]
    param()

    Invoke-SharingLinkCleanup -SiteName 'MexCentralFiles' -SiteUrl 'https://contoso.sharepoint.com/sites/MexCentralFiles'
}


Export-ModuleMember -Function 'Invoke-YFArchiveCleanup','Invoke-IBCCentralFilesArchiveCleanup','Invoke-MexCentralFilesArchiveCleanup','Invoke-ArchiveCleanup','Invoke-YFFileVersionCleanup','Invoke-IBCCentralFilesFileVersionCleanup','Invoke-MexCentralFilesFileVersionCleanup','Invoke-FileVersionCleanup','Invoke-SharingLinkCleanup','Invoke-YFSharingLinkCleanup','Invoke-IBCCentralFilesSharingLinkCleanup','Invoke-MexCentralFilesSharingLinkCleanup'
