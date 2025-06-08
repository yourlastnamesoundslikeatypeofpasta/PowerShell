function Select-SPToolsFolder {
    <#
    .SYNOPSIS
        Interactively choose a folder from a document library.
    .DESCRIPTION
        Recursively enumerates folders and prompts for a selection. A filter
        string can be provided to narrow results.
    .EXAMPLE
        Select-SPToolsFolder -SiteName 'Finance'
    #>
    [CmdletBinding()]
    param(
        [ValidatePattern('^[A-Za-z0-9_-]+$')]
        [string]$SiteName,
        [ValidateScript({ $_ -match '^https?://' })]
        [string]$SiteUrl,
        [ValidateNotNullOrEmpty()]
        [string]$LibraryName = 'Shared Documents',
        [string]$Filter,
        [string]$ClientId = $SharePointToolsSettings.ClientId,
        [string]$TenantId = $SharePointToolsSettings.TenantId,
        [string]$CertPath = $SharePointToolsSettings.CertPath
    )

    if (-not $SiteUrl) { $SiteUrl = Get-SPToolsSiteUrl -SiteName $SiteName }

    $conn = Get-PnPConnection -ErrorAction SilentlyContinue
    if (-not $conn) {
        Connect-SPToolsOnline -Url $SiteUrl -ClientId $ClientId -TenantId $TenantId -CertPath $CertPath
        $needsDisconnect = $true
    }

    $list  = Invoke-SPPnPCommand { Get-PnPList -Identity $LibraryName -ErrorAction Stop } 'Failed to retrieve list'
    $items = Invoke-SPPnPCommand { Get-PnPFolderItem -List $list -ItemType Folder -Recursive } 'Failed to list folders'
    $rootPath = $list.RootFolder.ServerRelativeUrl

    $folders = foreach ($item in $items) {
        $relative = $item.ServerRelativeUrl.Substring($rootPath.Length).TrimStart('/')
        [pscustomobject]@{ Path = $relative; Object = $item }
    }

    if ($Filter) { $folders = $folders | Where-Object { $_.Path -like "*$Filter*" } }
    if (-not $folders) { throw 'No folders found.' }

    $map = @{}
    $i = 0
    foreach ($f in $folders) {
        Write-STStatus "$i - $($f.Path)" -Level INFO
        $map[$i] = $f.Object
        $i++
    }

    do {
        $choice = Read-Host -Prompt 'Select folder number'
    } until ($map.ContainsKey([int]$choice))

    if ($needsDisconnect) { Disconnect-PnPOnline }

    $map[[int]$choice]
}

