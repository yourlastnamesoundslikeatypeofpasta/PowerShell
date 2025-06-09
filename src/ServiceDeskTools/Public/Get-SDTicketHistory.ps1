function Get-SDTicketHistory {
    <#
    .SYNOPSIS
        Retrieves audit history entries for a Service Desk incident.
    .PARAMETER Id
        Incident ID to retrieve history for.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
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

    Write-STLog -Message "Get-SDTicketHistory $Id" -Structured:$($env:ST_LOG_STRUCTURED -eq '1')
    if ($PSCmdlet.ShouldProcess("ticket $Id", 'Get history')) {
        $result = Invoke-SDRequest -Method 'GET' -Path "/incidents/$Id/audits.json" -ChaosMode:$ChaosMode
        return $result
    }
}

# Register argument completer for open ticket IDs
Register-ArgumentCompleter -CommandName Get-SDTicketHistory -ParameterName Id -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete)
    try {
        Invoke-SDRequest -Method 'GET' -Path '/incidents.json?state=open' |
            ForEach-Object id |
            Where-Object { $_ -like "$wordToComplete*" } |
            ForEach-Object {
                [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
            }
    }
    catch {
        # ignore completion errors
    }
}
