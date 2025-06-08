function Invoke-MexCentralFilesFileVersionCleanup {
    <#
    .SYNOPSIS
        Removes old file versions from the MexCentralFiles site.
    .EXAMPLE
        Invoke-MexCentralFilesFileVersionCleanup
    #>
    [CmdletBinding()]
    param()

    Invoke-FileVersionCleanup -SiteName 'MexCentralFiles'
}

<#
.SYNOPSIS
  Reports files with multiple versions.
.DESCRIPTION
  Generates a CSV of files with more than one version.
.EXAMPLE
    Invoke-FileVersionCleanup -SiteName 'Finance'
#>
