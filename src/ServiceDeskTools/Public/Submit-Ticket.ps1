function Submit-Ticket {
    <#
    .SYNOPSIS
        Creates a basic Service Desk incident.
    .DESCRIPTION
        Wrapper around New-SDTicket providing a simpler command name.
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Subject,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Description,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$RequesterEmail,
        [Parameter(Mandatory = $false)]
        [switch]$ChaosMode,
        [Parameter(Mandatory = $false)]
        [switch]$Explain
    )

    if ($Explain) {
        Get-Help $MyInvocation.PSCommandPath -Full
        return
    }

    $structured = $env:ST_LOG_STRUCTURED -eq '1'
    Write-STLog -Message "Submit-Ticket $Subject" -Structured:$structured
    if ($PSCmdlet.ShouldProcess("ticket $Subject", 'Create')) {
        New-SDTicket -Subject $Subject -Description $Description -RequesterEmail $RequesterEmail -ChaosMode:$ChaosMode
    }
}
