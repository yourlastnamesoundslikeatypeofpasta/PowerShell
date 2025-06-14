function Get-ServiceDeskAsset {
    <#
    .SYNOPSIS
        Retrieves asset details from the Service Desk.
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
    if ($PSCmdlet.ShouldProcess("asset $Id", 'Get')) {
        $params = @{ Method = 'GET'; Path = "/assets/$Id.json"; ChaosMode = $ChaosMode }
        if ($env:SD_ASSET_BASE_URI) { $params.BaseUri = $env:SD_ASSET_BASE_URI }
        return Invoke-SDRequest @params
    }
}
