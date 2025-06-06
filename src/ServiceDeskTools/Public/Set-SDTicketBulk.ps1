function Set-SDTicketBulk {
    <#
    .SYNOPSIS
        Applies field updates to multiple Service Desk incidents.
    .PARAMETER Id
        Array of incident IDs to update.
    .PARAMETER Fields
        Hashtable of fields to modify on each incident.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][int[]]$Id,
        [Parameter(Mandatory)][hashtable]$Fields,
        [switch]$ChaosMode
    )

    foreach ($ticketId in $Id) {
        Write-STLog "Set-SDTicketBulk $ticketId"
        Set-SDTicket -Id $ticketId -Fields $Fields -ChaosMode:$ChaosMode
    }
}
