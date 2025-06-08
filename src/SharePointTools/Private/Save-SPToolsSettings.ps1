function Save-SPToolsSettings {
    <#
    .SYNOPSIS
        Persists SharePoint Tools configuration to disk.
    .EXAMPLE
        Save-SPToolsSettings
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param()
    process {
        if ($PSCmdlet.ShouldProcess($settingsFile, 'Save configuration')) {
            Write-SPToolsHacker 'Saving configuration'
            $SharePointToolsSettings | Out-File -FilePath $settingsFile -Encoding utf8
            Write-SPToolsHacker 'Configuration saved' -Level SUCCESS -Metadata @{ Path = $settingsFile }
        }
    }
}

