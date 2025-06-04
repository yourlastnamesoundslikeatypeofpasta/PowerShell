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
        [string]$CsvPath,
        [string]$GroupName
    )

    $arguments = @()
    if ($PSBoundParameters.ContainsKey('CsvPath')) {
        $arguments += '-CsvPath'
        $arguments += $CsvPath
    }
    if ($PSBoundParameters.ContainsKey('GroupName')) {
        $arguments += '-GroupName'
        $arguments += $GroupName
    }

    Invoke-ScriptFile -Name 'AddUsersToGroup.ps1' -Args $arguments
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

function Invoke-ExchangeCalendarManager {
    [CmdletBinding()]
    param()

    if ($PSVersionTable.PSVersion.Major -lt 7) {
        throw 'This function requires PowerShell 7 or higher.'
    }

    Write-Verbose 'Checking ExchangeOnlineManagement module...'
    $module = Get-InstalledModule ExchangeOnlineManagement -ErrorAction SilentlyContinue
    $updateVersion = Find-Module -Name ExchangeOnlineManagement -ErrorAction SilentlyContinue

    if (-not $module) {
        Write-Host 'Installing Exchange Online module...'
        Install-Module -Name ExchangeOnlineManagement -Force
    } elseif ($updateVersion -and $module.Version -lt $updateVersion.Version) {
        Write-Host 'Updating Exchange Online module...'
        Update-Module -Name ExchangeOnlineManagement -Force
    }

    Import-Module ExchangeOnlineManagement

    try {
        Connect-ExchangeOnline -ErrorAction Stop
    } catch {
        Write-Warning "Failed to connect to Exchange Online: $($_.Exception.Message)"
        return
    }

    while ($true) {
        Write-Host ('-' * 88) -ForegroundColor Yellow
        Write-Host "1 - Grant calendar access" -ForegroundColor Yellow
        Write-Host "2 - Revoke calendar access" -ForegroundColor Yellow
        Write-Host "3 - Remove user's future meetings" -ForegroundColor Yellow
        Write-Host "4 - List mailbox permissions" -ForegroundColor Yellow
        Write-Host "Q - Quit" -ForegroundColor Yellow

        $selection = Read-Host 'Please make a selection'
        if ($selection -match '^[Qq]$') { break }

        switch ($selection) {
            '1' {
                $userCalendar = Read-Host 'Calendar owner (first.last)'
                $userRequesting = Read-Host 'Grant access to (first.last)'
                $accessRights = Read-Host 'AccessRights'
                Add-MailboxFolderPermission -Identity "$userCalendar:\Calendar" -User $userRequesting -AccessRights $accessRights
            }
            '2' {
                $userCalendar = Read-Host 'Calendar owner (first.last)'
                $userRequesting = Read-Host 'Remove access for (first.last)'
                Remove-MailboxFolderPermission -Identity "$userCalendar:\Calendar" -User $userRequesting -Confirm:$false
            }
            '3' {
                $userEmail = Read-Host 'User email (user@domain)'
                $daysOut = Read-Host 'Days of meetings to remove'
                Remove-CalendarEvents -Identity $userEmail -CancelOrganizedMeetings -QueryWindowInDays $daysOut
            }
            '4' {
                $userEmail = Read-Host 'User (first.last)'
                Get-Mailbox | Get-MailboxPermission -User $userEmail
            }
            default {
                Write-Host 'Invalid selection.' -ForegroundColor Red
            }
        }
    }

    Disconnect-ExchangeOnline -Confirm:$false
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
        [string]$SiteUrl,
        [string]$LibraryName = 'Shared Documents',
        [string]$ClientId = '<CLIENT-ID>',
        [string]$TenantId = '<TENANT-ID>',
        [string]$CertPath = '<PATH-TO-CERTIFICATE>',
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

function Invoke-SharingLinkCleanup {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$SiteName,
        [Parameter(Mandatory)]
        [string]$SiteUrl,
        [string]$LibraryName = 'Shared Documents',
        [string]$FolderName,
        [string]$ClientId = '<CLIENT-ID>',
        [string]$TenantId = '<TENANT-ID>',
        [string]$CertPath = '<PATH-TO-CERTIFICATE>'
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

# endregion

