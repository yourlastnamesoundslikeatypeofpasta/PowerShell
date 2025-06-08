function Set-SDTicket {
    <#
    .SYNOPSIS
        Updates an existing Service Desk incident.
    .PARAMETER Id
        Incident ID to update.
    .PARAMETER Fields
        Hashtable of fields to modify.
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [int]$Id,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [hashtable]$Fields,
        [Parameter(Mandatory = $false)]
        [switch]$ChaosMode,
        [Parameter(Mandatory = $false)]
        [switch]$Explain
    )

    if ($Explain) {
        Get-Help $MyInvocation.PSCommandPath -Full
        return
    }

    Write-STLog -Message "Set-SDTicket $Id"
    $body = @{ incident = $Fields }
    if ($PSCmdlet.ShouldProcess("ticket $Id", 'Update')) {
        Invoke-SDRequest -Method 'PUT' -Path "/incidents/$Id.json" -Body $body -ChaosMode:$ChaosMode
    }
}
