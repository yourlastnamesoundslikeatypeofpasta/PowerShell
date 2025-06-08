function Invoke-SharingLinkCleanup {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory = $true)]
        [ValidatePattern('^[A-Za-z0-9_-]+$')]
        [string]$SiteName,
        [ValidateScript({ $_ -match '^https?://' })]
        [string]$SiteUrl,
        [ValidateNotNullOrEmpty()]
        [string]$LibraryName = 'Shared Documents',
        [string]$FolderName,
        [string]$ClientId = $SharePointToolsSettings.ClientId,
        [string]$TenantId = $SharePointToolsSettings.TenantId,
        [string]$CertPath = $SharePointToolsSettings.CertPath,
        [string]$TranscriptPath
    )

    if (-not $SiteUrl) { $SiteUrl = Get-SPToolsSiteUrl -SiteName $SiteName }

    Connect-SPToolsOnline -Url $SiteUrl -ClientId $ClientId -TenantId $TenantId -CertPath $CertPath

    if (-not $TranscriptPath) {
        $TranscriptPath = "$env:USERPROFILE/SHAREPOINT_LINK_CLEANUP_${SiteName}_$(Get-Date -Format yyyyMMdd_HHmmss).log"
    }
    Start-Transcript -Path $TranscriptPath -Append

    if (-not $FolderName) {
        $targetFolder = Select-SPToolsFolder -SiteUrl $SiteUrl -LibraryName $LibraryName
    } else {
        $allFolders = Invoke-SPPnPCommand { Get-PnPFolderItem -List $LibraryName -ItemType Folder -Recursive } 'Failed to list folders'
        $targetFolder = $allFolders | Where-Object Name -eq $FolderName | Select-Object -First 1
        if (-not $targetFolder) { throw "Folder '$FolderName' not found." }
    }

    Write-STStatus "Scanning $($targetFolder.Name) for sharing links..." -Level INFO
    $items = Invoke-SPPnPCommand { $targetFolder | Get-PnPFolderItem -Recursive } 'Failed to list folder items'
    $removed = [System.Collections.Generic.List[string]]::new()

    if ($PSCmdlet.ShouldProcess($SiteName, 'Remove sharing links')) {
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
    }

    if ($removed.Count) {
        Write-STStatus 'Sharing links removed from the following items:' -Level WARN
        $removed | ForEach-Object { Write-STStatus $_ -Level WARN }
    } else {
        Write-STStatus 'No sharing links found.' -Level SUCCESS
    }

    Stop-Transcript
    Disconnect-PnPOnline
    Write-SPToolsHacker 'Recycle bin cleared'
}

