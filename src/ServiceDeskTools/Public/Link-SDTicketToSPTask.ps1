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
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][int]$TicketId,
        [Parameter(Mandatory)][string]$TaskUrl,
        [string]$FieldName = 'sharepoint_task_url',
        [switch]$ChaosMode,
        [switch]$Explain
    )

    if ($Explain) {
        Get-Help $MyInvocation.PSCommandPath -Full
        return
    }

    Write-STLog "Link-SDTicketToSPTask $TicketId $TaskUrl"
    $fields = @{ $FieldName = $TaskUrl }
    Set-SDTicket -Id $TicketId -Fields $fields -ChaosMode:$ChaosMode
}
