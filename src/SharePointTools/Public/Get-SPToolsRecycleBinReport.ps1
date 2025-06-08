function Get-SPToolsRecycleBinReport {
    <#
    .SYNOPSIS
        Creates a recycle bin usage report for a site.
    .PARAMETER SiteName
        Friendly site name.
    .EXAMPLE
        Get-SPToolsRecycleBinReport -SiteName 'Finance'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidatePattern('^[A-Za-z0-9_-]+$')]
        [string]$SiteName,
        [ValidateScript({ $_ -match '^https?://' })]
        [string]$SiteUrl,
        [string]$ClientId = $SharePointToolsSettings.ClientId,
        [string]$TenantId = $SharePointToolsSettings.TenantId,
        [string]$CertPath = $SharePointToolsSettings.CertPath
    )

    if (-not $SiteUrl) { $SiteUrl = Get-SPToolsSiteUrl -SiteName $SiteName }
    Write-SPToolsHacker "Recycle bin report: $SiteName"

    Connect-SPToolsOnline -Url $SiteUrl -ClientId $ClientId -TenantId $TenantId -CertPath $CertPath

    $items = Invoke-SPPnPCommand { Get-PnPRecycleBinItem } 'Failed to retrieve recycle bin items'
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

