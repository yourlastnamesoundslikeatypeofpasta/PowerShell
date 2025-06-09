function Remove-SDTicketAttachment {
    <#
    .SYNOPSIS
        Deletes an attachment from a Service Desk ticket.
    .PARAMETER Id
        Attachment ID to remove.
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
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

    Write-STLog -Message "Remove-SDTicketAttachment $Id"
    if ($PSCmdlet.ShouldProcess("attachment $Id", 'Remove')) {
        Invoke-SDRequest -Method 'DELETE' -Path "/attachments/$Id.json" -ChaosMode:$ChaosMode
        Write-STStatus "Removed attachment $Id" -Level SUCCESS -Log
        return [pscustomobject]@{ Id = $Id }
    }
}
