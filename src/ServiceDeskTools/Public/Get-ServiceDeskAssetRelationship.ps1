function Get-ServiceDeskAssetRelationship {
    <#
    .SYNOPSIS
        Retrieves relationships between Service Desk assets.
    .DESCRIPTION
        Queries the Service Desk API for asset relationships. Results can be
        filtered by asset ID and relationship type.
    .PARAMETER AssetId
        Only return relationships for the specified asset.
    .PARAMETER Type
        Only return relationships of this type.
    .PARAMETER ChaosMode
        Enables random delays and failures for chaos testing.
    .PARAMETER Explain
        Shows the full help content.
    .EXAMPLE
        Get-ServiceDeskAssetRelationship -AssetId 100 -Type 'Connected To'
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [int]$AssetId,
        [string]$Type,
        [switch]$ChaosMode,
        [switch]$Explain
    )

    if ($Explain) {
        Get-Help $MyInvocation.PSCommandPath -Full
        return
    }

    Write-STLog -Message "Get-ServiceDeskAssetRelationship $AssetId $Type" -Structured:$($env:ST_LOG_STRUCTURED -eq '1')
    $path = '/asset_relationships.json'
    $q = @()
    if ($PSBoundParameters.ContainsKey('AssetId')) { $q += "asset_id=$AssetId" }
    if ($PSBoundParameters.ContainsKey('Type')) { $q += "relationship_type=$( [uri]::EscapeDataString($Type) )" }
    if ($q) { $path += '?' + ($q -join '&') }

    if ($PSCmdlet.ShouldProcess('asset relationships', 'Get')) {
        return Invoke-SDRequest -Method 'GET' -Path $path -ChaosMode:$ChaosMode
    }
}
