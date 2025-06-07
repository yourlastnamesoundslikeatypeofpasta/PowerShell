function Submit-Ticket {
    <#
    .SYNOPSIS
        Creates a basic Service Desk incident.
    .DESCRIPTION
        Wrapper around New-SDTicket providing a simpler command name.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Subject,
        [Parameter(Mandatory)][string]$Description,
        [Parameter(Mandatory)][string]$RequesterEmail,
        [switch]$ChaosMode,
        [switch]$Explain
    )

    if ($Explain) {
        Get-Help $MyInvocation.PSCommandPath -Full
        return
    }

    Write-STLog -Message "Submit-Ticket $Subject"
    New-SDTicket -Subject $Subject -Description $Description -RequesterEmail $RequesterEmail -ChaosMode:$ChaosMode
}
