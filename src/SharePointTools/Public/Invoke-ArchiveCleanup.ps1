function Invoke-ArchiveCleanup {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory = $true)]
        [ValidatePattern('^[A-Za-z0-9_-]+$')]
        [string]$SiteName,
        [ValidateScript({ $_ -match '^https?://' })]
        [string]$SiteUrl,
        [ValidateNotNullOrEmpty()]
        [string]$LibraryName = 'Shared Documents',
        [string]$ClientId = $SharePointToolsSettings.ClientId,
        [string]$TenantId = $SharePointToolsSettings.TenantId,
        [string]$CertPath = $SharePointToolsSettings.CertPath,
        [string]$TranscriptPath
    )

    if (-not $SiteUrl) { $SiteUrl = Get-SPToolsSiteUrl -SiteName $SiteName }

    Connect-SPToolsOnline -Url $SiteUrl -ClientId $ClientId -TenantId $TenantId -CertPath $CertPath

    if (-not $TranscriptPath) {
        $TranscriptPath = "$env:USERPROFILE/SHAREPOINT_CLEANUP_${SiteName}_$(Get-Date -Format yyyyMMdd_HHmmss).log"
    }
    Start-Transcript -Path $TranscriptPath -Append

    Write-STStatus "[+] Scanning target: $SiteName" -Level INFO
    $items = Invoke-SPPnPCommand { Get-PnPListItem -List $LibraryName -PageSize 5000 } 'Failed to retrieve list items'

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

