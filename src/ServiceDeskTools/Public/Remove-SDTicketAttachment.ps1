function Remove-SDTicketAttachment {
    <#
    .SYNOPSIS
        Deletes an attachment from a Service Desk ticket.
    .PARAMETER Id
        Attachment ID to remove.
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

    Write-STLog -Message "Remove-SDTicketAttachment $Id" -Structured:$($env:ST_LOG_STRUCTURED -eq '1')
    if ($PSCmdlet.ShouldProcess("attachment $Id", 'Remove')) {
        Invoke-SDRequest -Method 'DELETE' -Path "/attachments/$Id.json" -ChaosMode:$ChaosMode
    }
}
