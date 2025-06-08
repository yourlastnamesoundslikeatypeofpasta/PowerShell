function Add-SPToolsSite {
    <#
    .SYNOPSIS
        Adds a new SharePoint site entry to the settings file.
    .PARAMETER Name
        Key used to reference the site.
    .PARAMETER Url
        Full URL of the SharePoint site.
    .EXAMPLE
        Add-SPToolsSite -Name 'Contoso' -Url 'https://contoso.sharepoint.com'
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
        if ($PSCmdlet.ShouldProcess($Name, 'Add site')) {
            Write-SPToolsHacker "Adding site $Name" -Metadata @{ Site = $Name; Url = $Url }
            $SharePointToolsSettings.Sites[$Name] = $Url
            Save-SPToolsSettings
            Write-SPToolsHacker 'Site added' -Level SUCCESS -Metadata @{ Site = $Name; Url = $Url }
        }
    }
}

