function Find-OrphanedSPFiles {
    <#
    .SYNOPSIS
        Finds files not modified within a given number of days.
    .EXAMPLE
        Find-OrphanedSPFiles -SiteUrl 'https://contoso.sharepoint.com' -Days 30
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateScript({ $_ -match '^https?://' })]
        [string]$SiteUrl,
        [ValidateNotNullOrEmpty()]
        [string]$LibraryName = 'Shared Documents',
        [ValidateRange(1, [int]::MaxValue)]
        [int]$Days = 90,
        [string]$ClientId = $SharePointToolsSettings.ClientId,
        [string]$TenantId = $SharePointToolsSettings.TenantId,
        [string]$CertPath = $SharePointToolsSettings.CertPath
    )

    Write-SPToolsHacker "Searching orphaned files on $SiteUrl"
    Connect-SPToolsOnline -Url $SiteUrl -ClientId $ClientId -TenantId $TenantId -CertPath $CertPath

    $cutoff = (Get-Date).AddDays(-$Days)
    $items = Invoke-SPPnPCommand { Get-PnPListItem -List $LibraryName -PageSize 2000 } 'Failed to retrieve list items'
    $report = foreach ($item in $items) {
        $file = Invoke-SPPnPCommand { Get-PnPProperty -ClientObject $item -Property File } 'Failed to get file properties'
        if ($file.TimeLastModified -lt $cutoff) {
            [pscustomobject]@{
                Name         = $file.Name
                Path         = $file.ServerRelativeUrl
                LastModified = $file.TimeLastModified
            }
        }
    }
    Disconnect-PnPOnline
    Write-SPToolsHacker 'Search complete'
    $report
}

