function Invoke-SPSiteAudit {
    <#
    .SYNOPSIS
        Runs library, recycle bin and preservation hold reports for a site.
    .DESCRIPTION
        Wrapper command that calls Get-SPToolsLibraryReport, Get-SPToolsRecycleBinReport
        and Get-SPToolsPreservationHoldReport for a specified site.
    .PARAMETER SiteName
        Friendly site name configured in settings.
    .PARAMETER SiteUrl
        Optional full site URL. If omitted the URL from settings is used.
    .EXAMPLE
        Invoke-SPSiteAudit -SiteName 'Finance'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidatePattern('^[A-Za-z0-9_-]+$')]
        [string]$SiteName,
        [ValidateScript({ $_ -match '^https?://' })]
        [string]$SiteUrl,
        [string]$ClientId = $SharePointToolsSettings.ClientId,
        [Alias('TenantID', 'tenantId')]
        [string]$TenantId = $SharePointToolsSettings.TenantId,
        [string]$CertPath = $SharePointToolsSettings.CertPath
    )

    if (-not $SiteUrl) { $SiteUrl = Get-SPToolsSiteUrl -SiteName $SiteName }
    Write-SPToolsHacker "Site audit: $SiteName"

    $library = Get-SPToolsLibraryReport -SiteName $SiteName -SiteUrl $SiteUrl -ClientId $ClientId -TenantId $TenantId -CertPath $CertPath
    $recycle = Get-SPToolsRecycleBinReport -SiteName $SiteName -SiteUrl $SiteUrl -ClientId $ClientId -TenantId $TenantId -CertPath $CertPath
    $hold = Get-SPToolsPreservationHoldReport -SiteName $SiteName -SiteUrl $SiteUrl -ClientId $ClientId -TenantId $TenantId -CertPath $CertPath

    Write-SPToolsHacker 'Audit complete'

    [pscustomobject]@{
        SiteName               = $SiteName
        LibraryReport          = $library
        RecycleBinReport       = $recycle
        PreservationHoldReport = $hold
    }
}
