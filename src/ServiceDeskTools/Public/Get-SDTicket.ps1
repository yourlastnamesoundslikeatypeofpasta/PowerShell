function Get-SDTicket {
    <#
    .SYNOPSIS
        Retrieves details for a Service Desk incident.
    .PARAMETER Id
        Incident ID to retrieve.
    #>
    [CmdletBinding()]
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

    Write-STLog -Message "Get-SDTicket $Id"
    Invoke-SDRequest -Method 'GET' -Path "/incidents/$Id.json" -ChaosMode:$ChaosMode
}
