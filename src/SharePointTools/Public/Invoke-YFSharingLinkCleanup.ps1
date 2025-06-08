function Invoke-YFSharingLinkCleanup {
    <#
    .SYNOPSIS
        Removes sharing links from the YF site.
    .EXAMPLE
        Invoke-YFSharingLinkCleanup
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param()

    Invoke-SharingLinkCleanup -SiteName 'YF'
}

