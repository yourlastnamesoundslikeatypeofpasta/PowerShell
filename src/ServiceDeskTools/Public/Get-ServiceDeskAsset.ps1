function Get-ServiceDeskAsset {
    <#
    .SYNOPSIS
        Retrieves details for a Service Desk asset.
    .PARAMETER Id
        Asset ID to retrieve.
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [int]$Id,
        [Parameter(Mandatory=$false)]
        [switch]$ChaosMode,
        [Parameter(Mandatory=$false)]
        [switch]$Explain
    )

    if ($Explain) {
        Get-Help $MyInvocation.PSCommandPath -Full
        return
    }

    Write-STLog -Message "Get-ServiceDeskAsset $Id"
    $path = "/assets/$Id.json"
    $base = $env:SD_ASSET_BASE_URI

    if ($PSCmdlet.ShouldProcess("asset $Id", 'Get')) {
        if ($base) {
            return Invoke-SDRequest -Method 'GET' -Path $path -BaseUri $base -ChaosMode:$ChaosMode
        }
        return Invoke-SDRequest -Method 'GET' -Path $path -ChaosMode:$ChaosMode
    }
}
