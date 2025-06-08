function Set-SPToolsSite {
    <#
    .SYNOPSIS
        Updates an existing SharePoint site entry.
    .PARAMETER Name
        Key used to reference the site.
    .PARAMETER Url
        New URL to set for the site.
    .EXAMPLE
        Set-SPToolsSite -Name 'Contoso' -Url 'https://contoso.sharepoint.com'
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory = $true)]
        [ValidatePattern('^[A-Za-z0-9_-]+$')]
        [string]$Name,
        [Parameter(Mandatory = $true)]
        [ValidateScript({ $_ -match '^https?://' })]
        [string]$Url
    )
    process {
        if ($PSCmdlet.ShouldProcess($Name, 'Update site')) {
            Write-SPToolsHacker "Updating site $Name" -Metadata @{ Site = $Name; Url = $Url }
            $SharePointToolsSettings.Sites[$Name] = $Url
            Save-SPToolsSettings
            Write-SPToolsHacker 'Site updated' -Level SUCCESS -Metadata @{ Site = $Name; Url = $Url }
        }
    }
}

