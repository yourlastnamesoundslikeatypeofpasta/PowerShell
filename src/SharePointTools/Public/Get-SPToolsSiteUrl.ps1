function Get-SPToolsSiteUrl {
    <#
    .SYNOPSIS
        Gets the site URL mapped to a given name.
    .PARAMETER SiteName
        Friendly name of the site.
    .EXAMPLE
        Get-SPToolsSiteUrl -SiteName 'MySite'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ $SharePointToolsSettings.Sites.ContainsKey($_) })]
        [string]$SiteName
    )
    process {
        Write-SPToolsHacker "Looking up $SiteName"
        $url = $SharePointToolsSettings.Sites[$SiteName]
        if (-not $url) { throw "Site '$SiteName' not found in settings." }
        Write-SPToolsHacker "URL found: $url"
        $url
    }
}

