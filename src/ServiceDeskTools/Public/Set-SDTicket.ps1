function Set-SDTicket {
    <#
    .SYNOPSIS
        Updates an existing Service Desk incident.
    .PARAMETER Id
        Incident ID to update.
    .PARAMETER Fields
        Hashtable of fields to modify.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][int]$Id,
        [Parameter(Mandatory)][hashtable]$Fields,
        [switch]$ChaosMode
    )

    Write-STLog "Set-SDTicket $Id"
    $body = @{ incident = $Fields }
    Invoke-SDRequest -Method 'PUT' -Path "/incidents/$Id.json" -Body $body -ChaosMode:$ChaosMode
}
