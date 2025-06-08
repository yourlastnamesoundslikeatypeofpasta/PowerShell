function Get-SDTicketHistory {
    <#
    .SYNOPSIS
        Retrieves audit history entries for a Service Desk incident.
    .PARAMETER Id
        Incident ID to retrieve history for.
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

    Write-STLog -Message "Get-SDTicketHistory $Id"
    if ($PSCmdlet.ShouldProcess("ticket $Id", 'Get history')) {
        $result = Invoke-SDRequest -Method 'GET' -Path "/incidents/$Id/audits.json" -ChaosMode:$ChaosMode
        return $result
    }
}
