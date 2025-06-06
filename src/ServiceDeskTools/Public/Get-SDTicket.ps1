function Get-SDTicket {
    <#
    .SYNOPSIS
        Retrieves details for a Service Desk incident.
    .PARAMETER Id
        Incident ID to retrieve.
    #>
    [CmdletBinding()]
    param([Parameter(Mandatory)][int]$Id)

    Write-STLog "Get-SDTicket $Id"
    Invoke-SDRequest -Method 'GET' -Path "/incidents/$Id.json"
}
