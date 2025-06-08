function Add-SDTicketComment {
    <#
    .SYNOPSIS
        Adds a comment to a Service Desk incident.
    .PARAMETER Id
        Incident ID to comment on.
    .PARAMETER Comment
        Text of the comment.
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [int]$Id,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Comment,
        [Parameter(Mandatory = $false)]
        [switch]$ChaosMode,
        [Parameter(Mandatory = $false)]
        [switch]$Explain
    )

    if ($Explain) {
        Get-Help $MyInvocation.PSCommandPath -Full
        return
    }

    Write-STLog -Message "Add-SDTicketComment $Id"
    $body = @{ comment = @{ body = $Comment } }
    if ($PSCmdlet.ShouldProcess("ticket $Id", 'Add comment')) {
        Invoke-SDRequest -Method 'POST' -Path "/incidents/$Id/comments.json" -Body $body -ChaosMode:$ChaosMode
    }
}
