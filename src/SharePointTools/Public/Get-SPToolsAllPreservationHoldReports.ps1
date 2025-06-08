function Get-SPToolsAllPreservationHoldReports {
    <#
    .SYNOPSIS
        Generates Preservation Hold Library reports for all sites.
    .EXAMPLE
        Get-SPToolsAllPreservationHoldReports
    #>
    [CmdletBinding()]
    param()
    Write-SPToolsHacker 'Generating all hold reports'
    foreach ($entry in $SharePointToolsSettings.Sites.GetEnumerator()) {
        Get-SPToolsPreservationHoldReport -SiteName $entry.Key -SiteUrl $entry.Value
    }
    Write-SPToolsHacker 'Reports complete'
}
