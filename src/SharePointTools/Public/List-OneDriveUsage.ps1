function List-OneDriveUsage {
    <#
    .SYNOPSIS
        Lists usage information for all OneDrive sites.
    .EXAMPLE
        List-OneDriveUsage -AdminUrl 'https://contoso-admin.sharepoint.com'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateScript({ $_ -match '^https?://' })]
        [string]$AdminUrl,
        [string]$ClientId = $SharePointToolsSettings.ClientId,
        [string]$TenantId = $SharePointToolsSettings.TenantId,
        [string]$CertPath = $SharePointToolsSettings.CertPath
    )

    Write-SPToolsHacker 'Gathering OneDrive usage'
    Connect-SPToolsOnline -Url $AdminUrl -ClientId $ClientId -TenantId $TenantId -CertPath $CertPath

    $sites = Invoke-SPPnPCommand { Get-PnPTenantSite -IncludeOneDriveSites } 'Failed to retrieve tenant sites'
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
Export-ModuleMember -Function 'Invoke-YFArchiveCleanup','Invoke-IBCCentralFilesArchiveCleanup','Invoke-MexCentralFilesArchiveCleanup','Invoke-ArchiveCleanup','Invoke-YFFileVersionCleanup','Invoke-IBCCentralFilesFileVersionCleanup','Invoke-MexCentralFilesFileVersionCleanup','Invoke-FileVersionCleanup','Invoke-SharingLinkCleanup','Invoke-YFSharingLinkCleanup','Invoke-IBCCentralFilesSharingLinkCleanup','Invoke-MexCentralFilesSharingLinkCleanup','Get-SPToolsSettings','Get-SPToolsSiteUrl','Add-SPToolsSite','Set-SPToolsSite','Remove-SPToolsSite','Get-SPToolsLibraryReport','Get-SPToolsAllLibraryReports','Get-SPToolsRecycleBinReport','Clear-SPToolsRecycleBin','Get-SPToolsAllRecycleBinReports','Get-SPToolsFileReport','Get-SPToolsPreservationHoldReport','Get-SPToolsAllPreservationHoldReports','Get-SPPermissionsReport','Clean-SPVersionHistory','Find-OrphanedSPFiles','Select-SPToolsFolder','List-OneDriveUsage','Test-SPToolsPrereqs' -Variable 'SharePointToolsSettings'

