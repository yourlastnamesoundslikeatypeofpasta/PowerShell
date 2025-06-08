function Invoke-MexCentralFilesSharingLinkCleanup {
    <#
    .SYNOPSIS
        Removes sharing links from the MexCentralFiles site.
    .EXAMPLE
        Invoke-MexCentralFilesSharingLinkCleanup
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param()

    Invoke-SharingLinkCleanup -SiteName 'MexCentralFiles'
}


