using module "..\TicketObject.psm1"
function Get-SDTicket {
    <#
    .SYNOPSIS
        Retrieves details for a Service Desk incident.
    .PARAMETER Id
        Incident ID to retrieve.
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    [OutputType([TicketObject])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [int]$Id,
        [Parameter(Mandatory = $false)]
        [switch]$ChaosMode,
        [Parameter(Mandatory = $false)]
        [switch]$Explain
    )

    if ($Explain) {
        Get-Help $MyInvocation.PSCommandPath -Full
        return
    }

    Write-STLog -Message "Get-SDTicket $Id"
    if ($PSCmdlet.ShouldProcess("ticket $Id", 'Get')) {
        $result = Invoke-SDRequest -Method 'GET' -Path "/incidents/$Id.json" -ChaosMode:$ChaosMode
        return [TicketObject]::FromApiResponse($result)
    }
}

# Register argument completer for open ticket IDs
Register-ArgumentCompleter -CommandName Get-SDTicket -ParameterName Id -ScriptBlock {
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
