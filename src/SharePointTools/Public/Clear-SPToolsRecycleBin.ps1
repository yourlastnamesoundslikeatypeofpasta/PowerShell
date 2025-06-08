function Clear-SPToolsRecycleBin {
    <#
    .SYNOPSIS
        Clears items from the SharePoint recycle bin.
    .PARAMETER SiteName
        Friendly site name.
    .EXAMPLE
        Clear-SPToolsRecycleBin -SiteName 'Finance' -SecondStage
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory = $true)]
        [ValidatePattern('^[A-Za-z0-9_-]+$')]
        [string]$SiteName,
        [ValidateScript({ $_ -match '^https?://' })]
        [string]$SiteUrl,
        [switch]$SecondStage,
        [string]$ClientId = $SharePointToolsSettings.ClientId,
        [string]$TenantId = $SharePointToolsSettings.TenantId,
        [string]$CertPath = $SharePointToolsSettings.CertPath
    )

    if (-not $SiteUrl) { $SiteUrl = Get-SPToolsSiteUrl -SiteName $SiteName }
    Write-SPToolsHacker "Clearing recycle bin: $SiteName"

    Connect-SPToolsOnline -Url $SiteUrl -ClientId $ClientId -TenantId $TenantId -CertPath $CertPath

    if ($PSCmdlet.ShouldProcess($SiteName, 'Clear recycle bin')) {
        try {
            if ($SecondStage) {
                Clear-PnPRecycleBinItem -SecondStage -Force
            } else {
                Clear-PnPRecycleBinItem -FirstStage -Force
            }
            Write-STStatus 'Recycle bin cleared' -Level SUCCESS
        } catch {
            Write-STStatus "Failed to clear recycle bin: $($_.Exception.Message)" -Level ERROR
        }
    }

    Disconnect-PnPOnline
}

