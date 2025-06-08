function Get-SPToolsLibraryReport {
    <#
    .SYNOPSIS
        Generates a report of document libraries for a site.
    .PARAMETER SiteName
        Friendly site name configured in settings.
    .PARAMETER SiteUrl
        Full URL of the site. If omitted the URL from settings is used.
    .EXAMPLE
        Get-SPToolsLibraryReport -SiteName 'Finance'
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
    Write-SPToolsHacker "Library report: $SiteName"

    Connect-SPToolsOnline -Url $SiteUrl -ClientId $ClientId -TenantId $TenantId -CertPath $CertPath

    $lists = Invoke-SPPnPCommand { Get-PnPList } 'Failed to retrieve lists' | Where-Object { $_.BaseTemplate -eq 101 }
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

