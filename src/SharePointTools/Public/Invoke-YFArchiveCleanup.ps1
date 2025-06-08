function Invoke-YFArchiveCleanup {
    <#
    .SYNOPSIS
        Removes archive items from the YF site.
    .EXAMPLE
        Invoke-YFArchiveCleanup
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param()

    Invoke-ArchiveCleanup -SiteName 'YF'
}

