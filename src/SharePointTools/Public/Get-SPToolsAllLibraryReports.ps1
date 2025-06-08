function Get-SPToolsAllLibraryReports {
    <#
    .SYNOPSIS
        Generates library reports for all configured sites.
    .EXAMPLE
        Get-SPToolsAllLibraryReports
    #>
    [CmdletBinding()]
    param()

    Write-SPToolsHacker 'Generating all library reports'

    foreach ($entry in $SharePointToolsSettings.Sites.GetEnumerator()) {
        Get-SPToolsLibraryReport -SiteName $entry.Key -SiteUrl $entry.Value
    }
    Write-SPToolsHacker 'Reports complete'
}

