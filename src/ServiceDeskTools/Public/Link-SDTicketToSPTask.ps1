function Link-SDTicketToSPTask {
    <#
    .SYNOPSIS
        Associates a Service Desk incident with a SharePoint task.
    .PARAMETER TicketId
        Service Desk incident ID.
    .PARAMETER TaskUrl
        URL of the related SharePoint task.
    .PARAMETER FieldName
        Name of the incident field storing the task URL.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [int]$TicketId,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$TaskUrl,
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$FieldName = 'sharepoint_task_url',
        [Parameter(Mandatory = $false)]
        [switch]$ChaosMode,
        [Parameter(Mandatory = $false)]
        [switch]$Explain
    )

    if ($Explain) {
        Get-Help $MyInvocation.PSCommandPath -Full
        return
    }

    Write-STLog -Message "Link-SDTicketToSPTask $TicketId $TaskUrl" -Structured:$($env:ST_LOG_STRUCTURED -eq '1')
    $fields = @{ $FieldName = $TaskUrl }
    if ($PSCmdlet.ShouldProcess("ticket $TicketId", 'Link to SP task')) {
        Set-SDTicket -Id $TicketId -Fields $fields -ChaosMode:$ChaosMode
    }
}
