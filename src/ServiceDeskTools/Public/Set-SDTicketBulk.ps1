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
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [int[]]$Id,
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

    foreach ($ticketId in $Id) {
        Write-STLog -Message "Set-SDTicketBulk $ticketId"
        Set-SDTicket -Id $ticketId -Fields $Fields -ChaosMode:$ChaosMode
    }
}
