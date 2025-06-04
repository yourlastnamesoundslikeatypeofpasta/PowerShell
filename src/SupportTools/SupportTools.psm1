function Invoke-ScriptFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name,
        [Parameter(ValueFromRemainingArguments=$true)]
        [object[]]$Args
    )
    $path = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath '..' | Join-Path -ChildPath "scripts/$Name"
    if (-not (Test-Path $path)) { throw "Script '$Name' not found." }
    & $path @Args
}

function AddUsersToGroup {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [object[]]$Arguments
    )
    Invoke-ScriptFile -Name "AddUsersToGroup.ps1" -Args $Arguments
}

function CleanupArchive {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [object[]]$Arguments
    )
    Invoke-ScriptFile -Name "CleanupArchive.ps1" -Args $Arguments
}

function Convert-ExcelToCsv {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [object[]]$Arguments
    )
    Invoke-ScriptFile -Name "Convert-ExcelToCsv.ps1" -Args $Arguments
}

function Get-CommonSystemInfo {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [object[]]$Arguments
    )
    Invoke-ScriptFile -Name "Get-CommonSystemInfo.ps1" -Args $Arguments
}

function Get-FailedLogins {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [object[]]$Arguments
    )
    Invoke-ScriptFile -Name "Get-FailedLogins.ps1" -Args $Arguments
}

function Get-NetworkShares {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [object[]]$Arguments
    )
    Invoke-ScriptFile -Name "Get-NetworkShares.ps1" -Args $Arguments
}

function Get-UniquePermissions {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [object[]]$Arguments
    )
    Invoke-ScriptFile -Name "Get-UniquePermissions.ps1" -Args $Arguments
}

function Install-Fonts {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [object[]]$Arguments
    )
    Invoke-ScriptFile -Name "Install-Fonts.ps1" -Args $Arguments
}

function PostInstallScript {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [object[]]$Arguments
    )
    Invoke-ScriptFile -Name "PostInstallScript.ps1" -Args $Arguments
}

function ProductKey {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [object[]]$Arguments
    )
    Invoke-ScriptFile -Name "ProductKey.ps1" -Args $Arguments
}

function SS_DEPLOYMENT_TEMPLATE {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [object[]]$Arguments
    )
    Invoke-ScriptFile -Name "SS_DEPLOYMENT_TEMPLATE.ps1" -Args $Arguments
}

function Search-ReadMe {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [object[]]$Arguments
    )
    Invoke-ScriptFile -Name "Search-ReadMe.ps1" -Args $Arguments
}

function Set-ComputerIPAddress {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [object[]]$Arguments
    )
    Invoke-ScriptFile -Name "Set-ComputerIPAddress.ps1" -Args $Arguments
}

function Set-NetAdapterMetering {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [object[]]$Arguments
    )
    Invoke-ScriptFile -Name "Set-NetAdapterMetering.ps1" -Args $Arguments
}

function Set-TimeZoneEasternStandardTime {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [object[]]$Arguments
    )
    Invoke-ScriptFile -Name "Set-TimeZoneEasternStandardTime.ps1" -Args $Arguments
}

function SimpleCountdown {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [object[]]$Arguments
    )
    Invoke-ScriptFile -Name "SimpleCountdown.ps1" -Args $Arguments
}

function Update-Sysmon {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [object[]]$Arguments
    )
    Invoke-ScriptFile -Name "Update-Sysmon.ps1" -Args $Arguments
}

# region SharePoint cleanup helpers

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

function Invoke-ArchiveCleanup {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$SiteName,
        [Parameter(Mandatory)]
        [string]$SiteUrl,
        [string]$LibraryName = 'Shared Documents',
        [string]$ClientId = '<CLIENT-ID>',
        [string]$TenantId = '<TENANT-ID>',
        [string]$CertPath = '<PATH-TO-CERTIFICATE>'
    )

    Import-Module PnP.PowerShell -ErrorAction Stop
    Connect-PnPOnline -Url $SiteUrl -ClientId $ClientId -Tenant $TenantId -CertificatePath $CertPath

    $logPath = "$env:USERPROFILE/SHAREPOINT_CLEANUP_${SiteName}_$(Get-Date -Format yyyyMMdd_HHmmss).log"
    Start-Transcript -Path $logPath -Append

    Write-Host "[+] Scanning target: $SiteName" -ForegroundColor Green
    $items = Get-PnPListItem -List $LibraryName -PageSize 5000

    $files   = $items | Where-Object { $_.FileSystemObjectType -eq 'File' }
    $folders = $items | Where-Object { $_.FileSystemObjectType -eq 'Folder' }

    $archivedFiles = $files | Where-Object { $_.FieldValues.FileRef -match 'zzz_Archive' }
    $archivedFolders = $folders | Where-Object { $_.FieldValues.FileRef -match 'zzz_Archive' }

    $filesDeleted = 0
    $foldersDeleted = 0

    Write-Host "[>] Located $($archivedFiles.Count) archived files marked for deletion." -ForegroundColor Cyan
    foreach ($file in $archivedFiles) {
        $filePath = $file.FieldValues.FileRef
        try {
            Write-Host "-- Deleting file: $filePath" -ForegroundColor DarkGray
            Remove-PnPFile -ServerRelativeUrl $filePath -Force -ErrorAction Stop
            $filesDeleted++
        } catch {
            Write-Warning "[!] FILE DELETE FAIL: $filePath :: $_"
        }
    }

    $archivedFoldersSorted = $archivedFolders | Sort-Object {
        ($_.FieldValues.FileRef -split '/').Count
    } -Descending

    Write-Host "[>] Initiating folder cleanup (leaf-first)" -ForegroundColor Yellow
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
            Write-Host "-- Deleting folder: $fullPath" -ForegroundColor Gray
            Remove-PnPFolder -Name $folderName -Folder $folderPath -Force -ErrorAction Stop
            $foldersDeleted++
        } catch {
            Write-Warning "[!] FOLDER DELETE FAIL: $fullPath :: $_"
        }
    }

    Write-Host "[✓] Cleanup complete for '$SiteName'. Log archived at $logPath" -ForegroundColor Green
    Write-Host "======== CLEANUP REPORT ($SiteName) ========" -ForegroundColor Magenta
    Write-Host "Total items scanned: $($items.Count)"
    Write-Host "Archived files found: $($archivedFiles.Count)"
    Write-Host "Archived folders found: $($archivedFolders.Count)"
    Write-Host "Files deleted: $filesDeleted"
    Write-Host "Folders deleted: $foldersDeleted"
    Write-Host "===========================================" -ForegroundColor Magenta
    Stop-Transcript
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

function Invoke-FileVersionCleanup {
    [CmdletBinding()]
    param(
        [string]$SiteName,
        [string]$SiteUrl
    )

    Write-Warning "Invoke-FileVersionCleanup is not yet implemented."
}

# endregion

