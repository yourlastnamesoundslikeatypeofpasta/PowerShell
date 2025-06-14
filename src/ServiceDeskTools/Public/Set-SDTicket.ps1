function Set-SDTicket {
    <#
    .SYNOPSIS
        Updates an existing Service Desk incident.
    .PARAMETER Id
        Incident ID to update.
    .PARAMETER Fields
        Hashtable of fields to modify.
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [int]$Id,
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

    Write-STLog -Message "Set-SDTicket $Id"
    $body = @{ incident = $Fields }
    if ($PSCmdlet.ShouldProcess("ticket $Id", 'Update')) {
        Invoke-SDRequest -Method 'PUT' -Path "/incidents/$Id.json" -Body $body -ChaosMode:$ChaosMode
    }
}

# Register argument completer for open ticket IDs
Register-ArgumentCompleter -CommandName Set-SDTicket -ParameterName Id -ScriptBlock {
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
