function Clean-SPVersionHistory {
    <#
    .SYNOPSIS
        Deletes old document versions from a library.
    .EXAMPLE
        Clean-SPVersionHistory -SiteUrl 'https://contoso.sharepoint.com'
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateScript({ $_ -match '^https?://' })]
        [string]$SiteUrl,
        [ValidateNotNullOrEmpty()]
        [string]$LibraryName = 'Shared Documents',
        [ValidateRange(1, [int]::MaxValue)]
        [int]$KeepVersions = 5,
        [string]$ClientId = $SharePointToolsSettings.ClientId,
        [string]$TenantId = $SharePointToolsSettings.TenantId,
        [string]$CertPath = $SharePointToolsSettings.CertPath
    )

    Write-SPToolsHacker "Cleaning versions on $SiteUrl"
    Connect-SPToolsOnline -Url $SiteUrl -ClientId $ClientId -TenantId $TenantId -CertPath $CertPath

    $items = Invoke-SPPnPCommand { Get-PnPListItem -List $LibraryName -PageSize 2000 } 'Failed to retrieve list items'
    if ($PSCmdlet.ShouldProcess($SiteUrl, 'Clean version history')) {
        foreach ($item in $items) {
            $versions = Invoke-SPPnPCommand { Get-PnPProperty -ClientObject $item -Property Versions } 'Failed to get versions'
            if ($versions.Count -gt $KeepVersions) {
                $excess = $versions | Sort-Object -Property Created -Descending | Select-Object -Skip $KeepVersions
                foreach ($v in $excess) { $v.DeleteObject() | Out-Null }
                Invoke-SPPnPCommand { Invoke-PnPQuery } 'Failed to execute query'
            }
        }
    }
    Disconnect-PnPOnline
    Write-SPToolsHacker 'Cleanup complete'
}

