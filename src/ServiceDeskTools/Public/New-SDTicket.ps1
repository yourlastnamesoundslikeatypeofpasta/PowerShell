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
    [CmdletBinding(SupportsShouldProcess = $true)]
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

    Write-STLog -Message "New-SDTicket $Subject" -Structured:$($env:ST_LOG_STRUCTURED -eq '1')
    $body = @{ incident = @{ name = $Subject; description = $Description; requester_email = $RequesterEmail } }
    if ($PSCmdlet.ShouldProcess("ticket $Subject", 'Create')) {
        Invoke-SDRequest -Method 'POST' -Path '/incidents.json' -Body $body -ChaosMode:$ChaosMode
    }
}
