function New-SDTicket {
    <#
    .SYNOPSIS
        Creates a new Service Desk incident.
    .PARAMETER Subject
        Subject of the incident.
    .PARAMETER Description
        Description of the incident.
    .PARAMETER RequesterEmail
        Email address of the requester.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Subject,
        [Parameter(Mandatory)][string]$Description,
        [Parameter(Mandatory)][string]$RequesterEmail
    )

    $body = @{ incident = @{ name = $Subject; description = $Description; requestor_email = $RequesterEmail } }
    Invoke-SDRequest -Method 'POST' -Path '/incidents.json' -Body $body
}
