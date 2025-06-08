function Invoke-MexCentralFilesArchiveCleanup {
    <#
    .SYNOPSIS
        Removes archive items from the MexCentralFiles site.
    .EXAMPLE
        Invoke-MexCentralFilesArchiveCleanup
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param()

    Invoke-ArchiveCleanup -SiteName 'MexCentralFiles'
}

<#
.SYNOPSIS
  Removes archive folders and files from a SharePoint library.
.DESCRIPTION
  Connects using PnP.PowerShell and deletes items matching zzz_Archive.
.EXAMPLE
    Invoke-ArchiveCleanup -SiteName 'Finance'
#>
