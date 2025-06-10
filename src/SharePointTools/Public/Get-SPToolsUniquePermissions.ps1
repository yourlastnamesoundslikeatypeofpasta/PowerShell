function Get-SPToolsUniquePermissions {
    <#
    .SYNOPSIS
        Returns items with unique role assignments in a library folder.
    .DESCRIPTION
        Connects to a SharePoint site and scans the specified library and folder
        for items that have unique permissions.
    .PARAMETER SiteUrl
        Full URL of the site.
    .PARAMETER LibraryName
        Name of the document library. Defaults to 'Shared Documents'.
    .PARAMETER RootFolder
        Folder path relative to the library root to scan.
    .PARAMETER ClientId
        Azure AD application client ID. Defaults to configuration.
    .PARAMETER TenantId
        Azure AD tenant ID. Defaults to configuration.
    .PARAMETER CertPath
        Path to the authentication certificate file. Defaults to configuration.
    .EXAMPLE
        Get-SPToolsUniquePermissions -SiteUrl https://contoso.sharepoint.com/sites/hr \ 
            -LibraryName "Shared Documents" -RootFolder "Sales/Private/2024"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateScript({ $_ -match '^https?://' })]
        [string]$SiteUrl,
        [ValidateNotNullOrEmpty()]
        [string]$LibraryName = 'Shared Documents',
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$RootFolder,
        [string]$ClientId = $SharePointToolsSettings.ClientId,
        [Alias('TenantID','tenantId')]
        [string]$TenantId = $SharePointToolsSettings.TenantId,
        [string]$CertPath = $SharePointToolsSettings.CertPath
    )

    Write-SPToolsHacker "Scanning $LibraryName/$RootFolder on $SiteUrl"
    Connect-SPToolsOnline -Url $SiteUrl -ClientId $ClientId -TenantId $TenantId -CertPath $CertPath

    try {
        $folderUrl = (Join-Path $LibraryName $RootFolder) -replace '\\','/'
        $folders = Invoke-SPPnPCommand { Get-PnPFolderItem -FolderSiteRelativeUrl $folderUrl -ItemType Folder -Recursive -Verbose } 'Failed to list folders'

        Write-STStatus -Message 'Getting PnP properties...' -Level INFO
        $itemsWithFields = foreach ($folder in $folders) {
            Invoke-SPPnPCommand { Get-PnPProperty -ClientObject $folder -Property ListItemAllFields } 'Failed to get item fields'
        }

        Write-STStatus -Message 'Getting PnP list items...' -Level INFO
        $items = foreach ($itm in $itemsWithFields) {
            try {
                Invoke-SPPnPCommand { Get-PnPListItem -List $LibraryName -Id $itm.Id -Fields 'HasUniqueRoleAssignments','ID','FileRef' }
            } catch {
                Write-STStatus "ITEM ID: $($itm.Id): MessageTooLarge" -Level WARN
            }
        }

        $unique = foreach ($item in $items) {
            Write-STStatus "Processing $($item.FieldValues.FileRef)" -Level INFO
            if ($item.HasUniqueRoleAssignments) {
                Write-STStatus "File has unique role assignments: $($item.FieldValues.FileRef)" -Level WARN
                [pscustomobject]@{
                    ID      = $item.FieldValues.ID
                    FileRef = $item.FieldValues.FileRef
                }
            }
        }
    } finally {
        Disconnect-PnPOnline -ErrorAction SilentlyContinue
    }

    Write-SPToolsHacker 'Scan complete'
    return $unique
}
