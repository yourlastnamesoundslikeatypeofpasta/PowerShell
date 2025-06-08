function Get-SPToolsAllRecycleBinReports {
    <#
    .SYNOPSIS
        Generates recycle bin reports for all configured sites.
    .EXAMPLE
        Get-SPToolsAllRecycleBinReports
    #>
    [CmdletBinding()]
    param()
    Write-SPToolsHacker 'Generating all recycle bin reports'
    foreach ($entry in $SharePointToolsSettings.Sites.GetEnumerator()) {
        Get-SPToolsRecycleBinReport -SiteName $entry.Key -SiteUrl $entry.Value
    }
    Write-SPToolsHacker 'Reports complete'
}

