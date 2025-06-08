function Get-SPToolsSettings {
    <#
    .SYNOPSIS
        Retrieves the current SharePoint Tools settings.
    .EXAMPLE
        Get-SPToolsSettings
    #>
    [CmdletBinding()]
    param()
    process {
        Write-SPToolsHacker 'Retrieving settings'
        $SharePointToolsSettings
    }
}

