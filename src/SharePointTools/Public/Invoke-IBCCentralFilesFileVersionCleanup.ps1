function Invoke-IBCCentralFilesFileVersionCleanup {
    <#
    .SYNOPSIS
        Removes old file versions from the IBCCentralFiles site.
    .EXAMPLE
        Invoke-IBCCentralFilesFileVersionCleanup
    #>
    [CmdletBinding()]
    param()

    Invoke-FileVersionCleanup -SiteName 'IBCCentralFiles'
}

