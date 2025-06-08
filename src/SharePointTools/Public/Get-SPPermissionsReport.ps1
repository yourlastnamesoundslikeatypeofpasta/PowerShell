function Get-SPPermissionsReport {
    <#
    .SYNOPSIS
        Retrieves permission assignments for a site or folder.
    .PARAMETER SiteUrl
        Full site URL.
    .PARAMETER FolderUrl
        Optional folder URL to limit the report.
    .EXAMPLE
        Get-SPPermissionsReport -SiteUrl 'https://contoso.sharepoint.com'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateScript({ $_ -match '^https?://' })]
        [string]$SiteUrl,
        [string]$FolderUrl,
        [string]$ClientId = $SharePointToolsSettings.ClientId,
        [string]$TenantId = $SharePointToolsSettings.TenantId,
        [string]$CertPath = $SharePointToolsSettings.CertPath
    )

    Write-SPToolsHacker "Permissions report: $SiteUrl"
    Connect-SPToolsOnline -Url $SiteUrl -ClientId $ClientId -TenantId $TenantId -CertPath $CertPath

    if ($FolderUrl) {
        $target = Invoke-SPPnPCommand { Get-PnPFolder -Url $FolderUrl } 'Failed to get folder'
    } else {
        $target = Invoke-SPPnPCommand { Get-PnPSite } 'Failed to get site'
    }

    $assignments = Invoke-SPPnPCommand { Get-PnPProperty -ClientObject $target -Property RoleAssignments } 'Failed to get role assignments'
    $report = foreach ($assignment in $assignments) {
        $member = Invoke-SPPnPCommand { Get-PnPProperty -ClientObject $assignment -Property Member } 'Failed to get member'
        $roles = Invoke-SPPnPCommand { Get-PnPProperty -ClientObject $assignment -Property RoleDefinitionBindings } 'Failed to get roles' | ForEach-Object { $_.Name } -join ','
        [pscustomobject]@{
            Member = $member.Title
            Type   = $member.PrincipalType
            Roles  = $roles
        }
    }

    Disconnect-PnPOnline
    Write-SPToolsHacker 'Report complete'
    $report
}

