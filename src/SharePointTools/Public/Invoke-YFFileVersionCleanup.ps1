function Invoke-YFFileVersionCleanup {
    <#
    .SYNOPSIS
        Removes old file versions from the YF site.
    .EXAMPLE
        Invoke-YFFileVersionCleanup
    #>
    [CmdletBinding()]
    param()

    Invoke-FileVersionCleanup -SiteName 'YF'
}

