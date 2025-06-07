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
    Write-STStatus 'PnP.PowerShell module not found. SharePoint functions may not work until it is installed.' -Level WARN
}

function Write-SPToolsHacker {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Message,
        [ValidateSet('INFO','SUCCESS','ERROR','WARN','SUB','FINAL','FATAL')]
        [string]$Level = 'INFO'
    )
    process {
        Write-STStatus -Message $Message -Level $Level -Log
    }

}

function Save-SPToolsSettings {
    <#
    .SYNOPSIS
        Persists SharePoint Tools configuration to disk.
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param()
    process {
        if ($PSCmdlet.ShouldProcess($settingsFile, 'Save configuration')) {
            Write-SPToolsHacker 'Saving configuration'
            $SharePointToolsSettings | Out-File -FilePath $settingsFile -Encoding utf8
            Write-SPToolsHacker 'Configuration saved'
        }
    }
}

function Get-SPToolsSettings {
    <#
    .SYNOPSIS
        Retrieves the current SharePoint Tools settings.
    #>
    [CmdletBinding()]
    param()
    process {
        Write-SPToolsHacker 'Retrieving settings'
        $SharePointToolsSettings
    }
}

function Get-SPToolsSiteUrl {
    <#
    .SYNOPSIS
        Gets the site URL mapped to a given name.
    .PARAMETER SiteName
        Friendly name of the site.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ $SharePointToolsSettings.Sites.ContainsKey($_) })]
        [string]$SiteName
    )
    process {
        Write-SPToolsHacker "Looking up $SiteName"
        $url = $SharePointToolsSettings.Sites[$SiteName]
        if (-not $url) { throw "Site '$SiteName' not found in settings." }
        Write-SPToolsHacker "URL found: $url"
        $url
    }
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
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory)]
        [ValidatePattern('^[A-Za-z0-9_-]+$')]
        [string]$Name,
        [Parameter(Mandatory)]
        [ValidateScript({ $_ -match '^https?://' })]
        [string]$Url
    )
    process {
        if ($PSCmdlet.ShouldProcess($Name, 'Add site')) {
            Write-SPToolsHacker "Adding site $Name"
            $SharePointToolsSettings.Sites[$Name] = $Url
            Save-SPToolsSettings
            Write-SPToolsHacker 'Site added'
        }
    }
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
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory)]
        [ValidatePattern('^[A-Za-z0-9_-]+$')]
        [string]$Name,
        [Parameter(Mandatory)]
        [ValidateScript({ $_ -match '^https?://' })]
        [string]$Url
    )
    process {
        if ($PSCmdlet.ShouldProcess($Name, 'Update site')) {
            Write-SPToolsHacker "Updating site $Name"
            $SharePointToolsSettings.Sites[$Name] = $Url
            Save-SPToolsSettings
            Write-SPToolsHacker 'Site updated'
        }
    }
}

function Remove-SPToolsSite {
    <#
    .SYNOPSIS
        Removes a SharePoint site entry from the settings file.
    .PARAMETER Name
        Key of the site to remove.
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory)]
        [ValidatePattern('^[A-Za-z0-9_-]+$')]
        [string]$Name
    )
    process {
        if ($PSCmdlet.ShouldProcess($Name, 'Remove site')) {
            Write-SPToolsHacker "Removing site $Name"
            [void]$SharePointToolsSettings.Sites.Remove($Name)
            Save-SPToolsSettings
            Write-SPToolsHacker 'Site removed'
        }
    }
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
    [CmdletBinding(SupportsShouldProcess=$true)]
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

    Write-STStatus "[+] Scanning target: $SiteName" -Level INFO
    $items = Get-PnPListItem -List $LibraryName -PageSize 5000

    $files   = $items | Where-Object { $_.FileSystemObjectType -eq 'File' }
    $folders = $items | Where-Object { $_.FileSystemObjectType -eq 'Folder' }

    $archivedFiles = $files | Where-Object { $_.FieldValues.FileRef -match 'zzz_Archive' }
    $archivedFolders = $folders | Where-Object { $_.FieldValues.FileRef -match 'zzz_Archive' }

    $filesDeleted = 0
    $foldersDeleted = 0

    Write-STStatus "[>] Located $($archivedFiles.Count) archived files marked for deletion." -Level INFO
    if ($PSCmdlet.ShouldProcess($SiteName, 'Remove archived files and folders')) {
        foreach ($file in $archivedFiles) {
            $filePath = $file.FieldValues.FileRef
            try {
                Write-STStatus "-- Deleting file: $filePath" -Level SUB
                Remove-PnPFile -ServerRelativeUrl $filePath -Force -ErrorAction Stop
                $filesDeleted++
            } catch {
                Write-STStatus "[!] FILE DELETE FAIL: $filePath :: $_" -Level WARN
            }
        }

    $archivedFoldersSorted = $archivedFolders | Sort-Object {
        ($_.FieldValues.FileRef -split '/').Count
    } -Descending

    Write-STStatus "[>] Initiating folder cleanup (leaf-first)" -Level INFO
    foreach ($folder in $archivedFoldersSorted) {
        $folderPath = $folder.FieldValues.FileDirRef
        $folderName = $folder.FieldValues.FileLeafRef
        $fullPath = "$folderPath/$folderName"

        $relativePath = $fullPath -replace '^.*?Shared Documents/?', ''
        $folderDepth = ($relativePath -split '/').Count
        if ($folderDepth -le 1) {
            Write-STStatus "-- Skipping root-level folder: $fullPath" -Level WARN
            continue
        }

        try {
            Write-STStatus "-- Deleting folder: $fullPath" -Level SUB
            Remove-PnPFolder -Name $folderName -Folder $folderPath -Force -ErrorAction Stop
            $foldersDeleted++
        } catch {
            Write-STStatus "[!] FOLDER DELETE FAIL: $fullPath :: $_" -Level WARN
        }
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

    Write-STStatus "Scanning target: $SiteName" -Level INFO
    $items = $targetFolder | Get-PnPFolderItem -Recursive -Verbose
    Write-STStatus "Located $($items.Count) files within $SiteUrl" -Level SUB

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
    Write-STStatus "Report exported to $ReportPath" -Level SUCCESS
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

    if (-not $FolderName) {
        $targetFolder = Select-SPToolsFolder -SiteUrl $SiteUrl -LibraryName $LibraryName
    } else {
        $allFolders = Get-PnPFolderItem -List $LibraryName -ItemType Folder -Recursive
        $targetFolder = $allFolders | Where-Object Name -eq $FolderName | Select-Object -First 1
        if (-not $targetFolder) { throw "Folder '$FolderName' not found." }
    }

    Write-STStatus "Scanning $($targetFolder.Name) for sharing links..." -Level INFO
    $items = $targetFolder | Get-PnPFolderItem -Recursive
    $removed = [System.Collections.Generic.List[string]]::new()

    foreach ($item in $items) {
        try {
            $link = (Get-PnPFileSharingLink -FileUrl $item.ServerRelativeUrl -ErrorAction Stop).Link.WebUrl
            if ($link) {
                Remove-PnPFileSharingLink -FileUrl $item.ServerRelativeUrl -Force -ErrorAction SilentlyContinue
                $removed.Add($item.ServerRelativeUrl)
                Write-STStatus "Removed file link: $($item.ServerRelativeUrl)" -Level WARN
            }
        } catch {
            try {
                $folderLink = (Get-PnPFolderSharingLink -Folder $item.ServerRelativeUrl -ErrorAction Stop).Link.WebUrl
                if ($folderLink) {
                    Remove-PnPFolderSharingLink -Folder $item.ServerRelativeUrl -Force -ErrorAction SilentlyContinue
                    $removed.Add($item.ServerRelativeUrl)
                    Write-STStatus "Removed folder link: $($item.ServerRelativeUrl)" -Level WARN
                }
            } catch {
                # ignore if no links exist
            }
        }
    }

    if ($removed.Count) {
        Write-STStatus 'Sharing links removed from the following items:' -Level WARN
        $removed | ForEach-Object { Write-STStatus $_ -Level WARN }
    } else {
        Write-STStatus 'No sharing links found.' -Level SUCCESS
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
    Write-SPToolsHacker "Library report: $SiteName"

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
    Write-SPToolsHacker 'Report complete'
    $report
}

function Get-SPToolsAllLibraryReports {
    [CmdletBinding()]
    param()

    Write-SPToolsHacker 'Generating all library reports'

    foreach ($entry in $SharePointToolsSettings.Sites.GetEnumerator()) {
        Get-SPToolsLibraryReport -SiteName $entry.Key -SiteUrl $entry.Value
    }
    Write-SPToolsHacker 'Reports complete'
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
    Write-SPToolsHacker "Recycle bin report: $SiteName"

    Connect-PnPOnline -Url $SiteUrl -ClientId $ClientId -Tenant $TenantId -CertificatePath $CertPath

    $items = Get-PnPRecycleBinItem
    $totalSize = ($items | Measure-Object -Property Size -Sum).Sum
    $report = [pscustomobject]@{
        SiteName    = $SiteName
        ItemCount   = $items.Count
        TotalSizeMB = [math]::Round($totalSize / 1MB, 2)
    }

    Disconnect-PnPOnline
    Write-SPToolsHacker 'Report complete'
    $report
}

function Clear-SPToolsRecycleBin {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory)][string]$SiteName,
        [string]$SiteUrl,
        [switch]$SecondStage,
        [string]$ClientId = $SharePointToolsSettings.ClientId,
        [string]$TenantId = $SharePointToolsSettings.TenantId,
        [string]$CertPath = $SharePointToolsSettings.CertPath
    )

    if (-not $SiteUrl) { $SiteUrl = Get-SPToolsSiteUrl -SiteName $SiteName }
    Write-SPToolsHacker "Clearing recycle bin: $SiteName"

    Connect-PnPOnline -Url $SiteUrl -ClientId $ClientId -Tenant $TenantId -CertificatePath $CertPath

    if ($PSCmdlet.ShouldProcess($SiteName, 'Clear recycle bin')) {
        if ($SecondStage) {
            Clear-PnPRecycleBinItem -SecondStage -Force
        } else {
            Clear-PnPRecycleBinItem -FirstStage -Force
        }
    }

    Disconnect-PnPOnline
    Write-SPToolsHacker 'Recycle bin cleared'
}

function Get-SPToolsAllRecycleBinReports {
    [CmdletBinding()]
    param()
    Write-SPToolsHacker 'Generating all recycle bin reports'
    foreach ($entry in $SharePointToolsSettings.Sites.GetEnumerator()) {
        Get-SPToolsRecycleBinReport -SiteName $entry.Key -SiteUrl $entry.Value
    }
    Write-SPToolsHacker 'Reports complete'
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
    Write-SPToolsHacker "Hold report: $SiteName"

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
    Write-SPToolsHacker 'Report complete'
    $report
}

function Get-SPToolsAllPreservationHoldReports {
    [CmdletBinding()]
    param()
    Write-SPToolsHacker 'Generating all hold reports'
    foreach ($entry in $SharePointToolsSettings.Sites.GetEnumerator()) {
        Get-SPToolsPreservationHoldReport -SiteName $entry.Key -SiteUrl $entry.Value
    }
    Write-SPToolsHacker 'Reports complete'
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

    Write-SPToolsHacker "Permissions report: $SiteUrl"
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
    Write-SPToolsHacker 'Report complete'
    $report
}

function Clean-SPVersionHistory {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory)][string]$SiteUrl,
        [string]$LibraryName = 'Shared Documents',
        [int]$KeepVersions = 5,
        [string]$ClientId = $SharePointToolsSettings.ClientId,
        [string]$TenantId = $SharePointToolsSettings.TenantId,
        [string]$CertPath = $SharePointToolsSettings.CertPath
    )

    Write-SPToolsHacker "Cleaning versions on $SiteUrl"
    Connect-PnPOnline -Url $SiteUrl -ClientId $ClientId -Tenant $TenantId -CertificatePath $CertPath

    $items = Get-PnPListItem -List $LibraryName -PageSize 2000
    if ($PSCmdlet.ShouldProcess($SiteUrl, 'Clean version history')) {
        foreach ($item in $items) {
            $versions = Get-PnPProperty -ClientObject $item -Property Versions
            if ($versions.Count -gt $KeepVersions) {
                $excess = $versions | Sort-Object -Property Created -Descending | Select-Object -Skip $KeepVersions
                foreach ($v in $excess) { $v.DeleteObject() | Out-Null }
                Invoke-PnPQuery
            }
        }
    }
    Disconnect-PnPOnline
    Write-SPToolsHacker 'Cleanup complete'
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

    Write-SPToolsHacker "Searching orphaned files on $SiteUrl"
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
    Write-SPToolsHacker 'Search complete'
    $report
}

function Select-SPToolsFolder {
    <#
    .SYNOPSIS
        Interactively choose a folder from a document library.
    .DESCRIPTION
        Recursively enumerates folders and prompts for a selection. A filter
        string can be provided to narrow results.
    #>
    [CmdletBinding()]
    param(
        [string]$SiteName,
        [string]$SiteUrl,
        [string]$LibraryName = 'Shared Documents',
        [string]$Filter,
        [string]$ClientId = $SharePointToolsSettings.ClientId,
        [string]$TenantId = $SharePointToolsSettings.TenantId,
        [string]$CertPath = $SharePointToolsSettings.CertPath
    )

    if (-not $SiteUrl) { $SiteUrl = Get-SPToolsSiteUrl -SiteName $SiteName }

    $conn = Get-PnPConnection -ErrorAction SilentlyContinue
    if (-not $conn) {
        Connect-PnPOnline -Url $SiteUrl -ClientId $ClientId -Tenant $TenantId -CertificatePath $CertPath
        $needsDisconnect = $true
    }

    $list = Get-PnPList -Identity $LibraryName -ErrorAction Stop
    $items = Get-PnPFolderItem -List $list -ItemType Folder -Recursive
    $rootPath = $list.RootFolder.ServerRelativeUrl

    $folders = foreach ($item in $items) {
        $relative = $item.ServerRelativeUrl.Substring($rootPath.Length).TrimStart('/')
        [pscustomobject]@{ Path = $relative; Object = $item }
    }

    if ($Filter) { $folders = $folders | Where-Object { $_.Path -like "*$Filter*" } }
    if (-not $folders) { throw 'No folders found.' }

    $map = @{}
    $i = 0
    foreach ($f in $folders) {
        Write-STStatus "$i - $($f.Path)" -Level INFO
        $map[$i] = $f.Object
        $i++
    }

    do {
        $choice = Read-Host -Prompt 'Select folder number'
    } until ($map.ContainsKey([int]$choice))

    if ($needsDisconnect) { Disconnect-PnPOnline }

    $map[[int]$choice]
}

function Get-SPToolsFileReport {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$SiteName,
        [string]$SiteUrl,
        [string]$LibraryName = 'Documents',
        [string]$ClientId = $SharePointToolsSettings.ClientId,
        [string]$TenantId = $SharePointToolsSettings.TenantId,
        [string]$CertPath = $SharePointToolsSettings.CertPath,
        [string]$ReportPath,
        [int]$PageSize = 5000
    )

    if (-not $SiteUrl) { $SiteUrl = Get-SPToolsSiteUrl -SiteName $SiteName }
    Write-SPToolsHacker "File report: $SiteName"

    Connect-PnPOnline -Url $SiteUrl -ClientId $ClientId -Tenant $TenantId -CertificatePath $CertPath

    $items = Get-PnPListItem -List $LibraryName -PageSize $PageSize
    $files = $items | Where-Object { $_.FileSystemObjectType -eq 'File' }
    $report = [System.Collections.Generic.List[object]]::new()

    foreach ($file in $files) {
        try {
            $field = $file.FieldValues
            $obj = [pscustomobject]@{
                FileName             = $field['FileLeafRef']
                FileType             = $field['File_x0020_Type']
                FileSizeBytes        = [int64]$field['File_x0020_Size']
                CreatedDate          = [datetime]$field['Created_x0020_Date']
                LastModifiedDate     = [datetime]$field['Last_x0020_Modified']
                CreatedBy            = $field['Created_x0020_By']
                ModifiedBy           = $field['Modified_x0020_By']
                FilePath             = $field['FileRef']
                DirectoryPath        = $field['FileDirRef']
                UniqueId             = $field['UniqueId']
                ParentUniqueId       = $field['ParentUniqueId']
                SharePointItemId     = $field['ID']
                ContentTypeId        = $field['ContentTypeId']
                ComplianceAssetId    = $field['ComplianceAssetId']
                VirusScanStatus      = $field['_VirusStatus']
                RansomwareMetadata   = $field['_RansomwareAnomalyMetaInfo']
                IsCurrentVersion     = $field['_IsCurrentVersion']
                CreatedDisplayDate   = [datetime]$field['Created']
                ModifiedDisplayDate  = [datetime]$field['Modified']
                VersionString        = $field['_UIVersionString']
                VersionNumber        = $field['_UIVersion']
                DocGUID              = $field['GUID']
                LastScanDate         = [datetime]$field['SMLastModifiedDate']
                StorageStreamSize    = [int64]$field['SMTotalFileStreamSize']
                MigrationId          = $field['MigrationWizId']
                MigrationVersion     = $field['MigrationWizIdVersion']
                OrderIndex           = $field['Order']
                StreamHash           = $field['StreamHash']
                ConcurrencyNumber    = $field['DocConcurrencyNumber']
            }
            $report.Add($obj)
        }
        catch {
            Write-STStatus "Error processing file: $_" -Level WARN
        }
    }

    Disconnect-PnPOnline

    if ($ReportPath) {
        $report | Export-Csv $ReportPath -NoTypeInformation
        Write-SPToolsHacker "Report exported to $ReportPath" -Level SUCCESS
    }

    Write-SPToolsHacker 'File report complete'
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

    Write-SPToolsHacker 'Gathering OneDrive usage'
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
    Write-SPToolsHacker 'Report complete'
    $report
}
Export-ModuleMember -Function 'Invoke-YFArchiveCleanup','Invoke-IBCCentralFilesArchiveCleanup','Invoke-MexCentralFilesArchiveCleanup','Invoke-ArchiveCleanup','Invoke-YFFileVersionCleanup','Invoke-IBCCentralFilesFileVersionCleanup','Invoke-MexCentralFilesFileVersionCleanup','Invoke-FileVersionCleanup','Invoke-SharingLinkCleanup','Invoke-YFSharingLinkCleanup','Invoke-IBCCentralFilesSharingLinkCleanup','Invoke-MexCentralFilesSharingLinkCleanup','Get-SPToolsSettings','Get-SPToolsSiteUrl','Add-SPToolsSite','Set-SPToolsSite','Remove-SPToolsSite','Get-SPToolsLibraryReport','Get-SPToolsAllLibraryReports','Get-SPToolsRecycleBinReport','Clear-SPToolsRecycleBin','Get-SPToolsAllRecycleBinReports','Get-SPToolsFileReport','Get-SPToolsPreservationHoldReport','Get-SPToolsAllPreservationHoldReports','Get-SPPermissionsReport','Clean-SPVersionHistory','Find-OrphanedSPFiles','Select-SPToolsFolder','List-OneDriveUsage' -Variable 'SharePointToolsSettings'

function Register-SPToolsCompleters {
    $siteCmds = 'Get-SPToolsSiteUrl','Get-SPToolsLibraryReport','Get-SPToolsRecycleBinReport','Clear-SPToolsRecycleBin','Get-SPToolsPreservationHoldReport','Get-SPToolsAllLibraryReports','Get-SPToolsAllRecycleBinReports','Get-SPToolsFileReport','Select-SPToolsFolder'
    Register-ArgumentCompleter -CommandName $siteCmds -ParameterName SiteName -ScriptBlock {
        param($commandName,$parameterName,$wordToComplete)
        $SharePointToolsSettings.Sites.Keys | Where-Object { $_ -like "$wordToComplete*" } |
            ForEach-Object { [System.Management.Automation.CompletionResult]::new($_,$_, 'ParameterValue', $_) }
    }
}

function Show-SharePointToolsBanner {
    Write-STDivider 'SHAREPOINTTOOLS MODULE LOADED' -Style heavy
    Write-STStatus "Run 'Get-Command -Module SharePointTools' to view available tools." -Level SUB
    Write-STLog -Message 'SharePointTools module loaded'
}

Register-SPToolsCompleters
Show-SharePointToolsBanner
