function Invoke-IBCCentralFilesSharingLinkCleanup {
    <#
    .SYNOPSIS
        Removes sharing links from the IBCCentralFiles site.
    .EXAMPLE
        Invoke-IBCCentralFilesSharingLinkCleanup
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param()

    Invoke-SharingLinkCleanup -SiteName 'IBCCentralFiles'
}

