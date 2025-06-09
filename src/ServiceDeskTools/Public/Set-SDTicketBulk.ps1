function Set-SDTicketBulk {
    <#
    .SYNOPSIS
        Applies field updates to multiple Service Desk incidents.
    .PARAMETER Id
        Array of incident IDs to update.
    .PARAMETER Fields
        Hashtable of fields to modify on each incident.
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [int[]]$Id,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [hashtable]$Fields,
        [Parameter(Mandatory = $false)]
        [switch]$ChaosMode,
        [Parameter(Mandatory = $false)]
        [switch]$Explain
    )

    if ($Explain) {
        Get-Help $MyInvocation.PSCommandPath -Full
        return
    }

    foreach ($ticketId in $Id) {
        Write-STLog -Message "Set-SDTicketBulk $ticketId"
        if ($PSCmdlet.ShouldProcess("ticket $ticketId", 'Update')) {
            Set-SDTicket -Id $ticketId -Fields $Fields -ChaosMode:$ChaosMode
        }
    }
}

# Register argument completer for open ticket IDs
Register-ArgumentCompleter -CommandName Set-SDTicketBulk -ParameterName Id -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete)
    try {
        Invoke-SDRequest -Method 'GET' -Path '/incidents.json?state=open' |
            ForEach-Object id |
            Where-Object { $_ -like "$wordToComplete*" } |
            ForEach-Object {
                [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
            }
    } catch {
        # ignore completion errors
    }
}
