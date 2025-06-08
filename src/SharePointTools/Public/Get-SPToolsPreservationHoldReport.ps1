function Get-SPToolsPreservationHoldReport {
    <#
    .SYNOPSIS
        Reports the size of the Preservation Hold Library.
    .NOTES
        Uses PnP.PowerShell commands. See https://pnp.github.io/powershell/ for details.
    .EXAMPLE
        Get-SPToolsPreservationHoldReport -SiteName 'Finance'
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
    Write-SPToolsHacker "Hold report: $SiteName"

    Connect-SPToolsOnline -Url $SiteUrl -ClientId $ClientId -TenantId $TenantId -CertPath $CertPath

    $items = Invoke-SPPnPCommand { Get-PnPListItem -List 'Preservation Hold Library' -PageSize 2000 } 'Failed to retrieve hold items'
    $files = foreach ($item in $items) { Invoke-SPPnPCommand { Get-PnPProperty -ClientObject $item -Property File } 'Failed to get file info' }
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

