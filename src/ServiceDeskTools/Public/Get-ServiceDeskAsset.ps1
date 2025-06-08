function Get-ServiceDeskAsset {
    <#
    .SYNOPSIS
        Retrieves details for a Service Desk asset.
    .PARAMETER Id
        Asset ID to retrieve.
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    [OutputType([psobject])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [int]$Id,
        [Parameter(Mandatory = $false)]
        [switch]$ChaosMode,
        [Parameter(Mandatory = $false)]
        [switch]$Explain
    )

    if ($Explain) {
        Get-Help $MyInvocation.PSCommandPath -Full
        return
    }

    Write-STLog -Message "Get-ServiceDeskAsset $Id"
    if ($PSCmdlet.ShouldProcess("asset $Id", 'Get')) {
        $result = Invoke-SDRequest -Method 'GET' -Path "/assets/$Id.json" -ChaosMode:$ChaosMode
        return $result
    }
}
