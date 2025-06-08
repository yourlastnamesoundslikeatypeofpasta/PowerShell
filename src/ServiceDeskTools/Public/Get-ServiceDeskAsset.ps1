function Get-ServiceDeskAsset {
    <#
    .SYNOPSIS
        Retrieves a Service Desk asset by ID.
    .PARAMETER Id
        Asset ID to retrieve.
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][int]$Id,
        [switch]$ChaosMode,
        [switch]$Explain
    )

    if ($Explain) {
        Get-Help $MyInvocation.PSCommandPath -Full
        return
    }

    Write-STLog -Message "Get-ServiceDeskAsset $Id"
    $assetBase = if ($env:SD_ASSET_BASE_URI) { $env:SD_ASSET_BASE_URI } else { $null }
    if (-not $assetBase) { $assetBase = $env:SD_BASE_URI }
    if ($PSCmdlet.ShouldProcess("asset $Id", 'Get')) {
        if ($assetBase) {
            return Invoke-SDRequest -Method 'GET' -Path "/assets/$Id.json" -ChaosMode:$ChaosMode -BaseUri $assetBase
        } else {
            return Invoke-SDRequest -Method 'GET' -Path "/assets/$Id.json" -ChaosMode:$ChaosMode
        }
    }
}
