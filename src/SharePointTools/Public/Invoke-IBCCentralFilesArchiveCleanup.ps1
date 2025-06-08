function Invoke-IBCCentralFilesArchiveCleanup {
    <#
    .SYNOPSIS
        Removes archive items from the IBCCentralFiles site.
    .EXAMPLE
        Invoke-IBCCentralFilesArchiveCleanup
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param()

    Invoke-ArchiveCleanup -SiteName 'IBCCentralFiles'
}

