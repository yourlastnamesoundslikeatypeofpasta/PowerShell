function Get-ServiceDeskRelationship {
    <#
    .SYNOPSIS
        Retrieves asset relationship records from the Service Desk.
    .DESCRIPTION
        Queries the Service Desk API for asset relationships. Results can be
        filtered by asset identifier and relationship type.
    .PARAMETER AssetId
        Optional asset ID to filter relationships.
    .PARAMETER Type
        Optional relationship type to filter results.
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter()] [int]$AssetId,
        [Parameter()] [string]$Type,
        [switch]$ChaosMode,
        [switch]$Explain
    )

    if ($Explain) {
        Get-Help $MyInvocation.PSCommandPath -Full
        return
    }

    Write-STLog -Message "Get-ServiceDeskRelationship $AssetId $Type"

    $path = '/asset_relationships.json'
    $query = @()
    if ($PSBoundParameters.ContainsKey('AssetId')) {
        $query += 'asset_id=' + [uri]::EscapeDataString($AssetId)
    }
    if ($PSBoundParameters.ContainsKey('Type')) {
        $query += 'relationship_type=' + [uri]::EscapeDataString($Type)
    }
    if ($query.Count -gt 0) { $path += '?' + ($query -join '&') }

    $params = @{ Method = 'GET'; Path = $path; ChaosMode = $ChaosMode }
    if ($env:SD_ASSET_BASE_URI) { $params.BaseUri = $env:SD_ASSET_BASE_URI }

    if ($PSCmdlet.ShouldProcess('asset relationships', 'Get')) {
        return Invoke-SDRequest @params
    }
}
