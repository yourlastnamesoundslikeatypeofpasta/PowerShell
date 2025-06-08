function Invoke-FileVersionCleanup {
    [CmdletBinding()]
    param(
        [ValidatePattern('^[A-Za-z0-9_-]+$')]
        [string]$SiteName,
        [ValidateScript({ $_ -match '^https?://' })]
        [string]$SiteUrl,
        [ValidateNotNullOrEmpty()]
        [string]$LibraryName = 'Shared Documents',
        [string]$ClientId = $SharePointToolsSettings.ClientId,
        [string]$TenantId = $SharePointToolsSettings.TenantId,
        [string]$CertPath = $SharePointToolsSettings.CertPath,
        [string]$ReportPath = 'exportedReport.csv'
    )

    if (-not $SiteUrl) { $SiteUrl = Get-SPToolsSiteUrl -SiteName $SiteName }

    Connect-SPToolsOnline -Url $SiteUrl -ClientId $ClientId -TenantId $TenantId -CertPath $CertPath

    $rootFolder = Invoke-SPPnPCommand { Get-PnPFolder -ListRootFolder $LibraryName } 'Failed to get root folder'
    $subFolders = Invoke-SPPnPCommand { $rootFolder | Get-PnPFolderInFolder } 'Failed to enumerate folders'
    $targetFolder = $subFolders | Where-Object { $_.Name -eq 'Marketing' }

    Write-STStatus "Scanning target: $SiteName" -Level INFO
    $items = Invoke-SPPnPCommand { $targetFolder | Get-PnPFolderItem -Recursive -Verbose } 'Failed to list folder items'
    Write-STStatus "Located $($items.Count) files within $SiteUrl" -Level SUB

    $files = $items | Where-Object { $_.GetType().Name -eq 'File' }

    $report = foreach ($file in $files) {
        $versions = Invoke-SPPnPCommand { Get-PnPProperty -ClientObject $file -Property Versions } 'Failed to get versions'
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
.EXAMPLE
    Invoke-SharingLinkCleanup -SiteName 'Finance'
#>
