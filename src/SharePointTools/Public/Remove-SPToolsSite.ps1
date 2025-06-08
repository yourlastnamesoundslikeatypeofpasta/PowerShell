function Remove-SPToolsSite {
    <#
    .SYNOPSIS
        Removes a SharePoint site entry from the settings file.
    .PARAMETER Name
        Key of the site to remove.
    .EXAMPLE
        Remove-SPToolsSite -Name 'Contoso'
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory = $true)]
        [ValidatePattern('^[A-Za-z0-9_-]+$')]
        [string]$Name
    )
    process {
        if ($PSCmdlet.ShouldProcess($Name, 'Remove site')) {
            Write-SPToolsHacker "Removing site $Name" -Metadata @{ Site = $Name }
            [void]$SharePointToolsSettings.Sites.Remove($Name)
            Save-SPToolsSettings
            Write-SPToolsHacker 'Site removed' -Level SUCCESS -Metadata @{ Site = $Name }
        }
    }
}


