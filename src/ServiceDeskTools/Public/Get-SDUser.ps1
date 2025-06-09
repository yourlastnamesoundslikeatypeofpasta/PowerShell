function Get-SDUser {
    <#
    .SYNOPSIS
        Retrieves user details from the Service Desk.
    .DESCRIPTION
        Queries the Service Desk /users API for information about a single user
        by id or email address.
    .PARAMETER Id
        Numeric id of the user to retrieve.
    .PARAMETER Email
        Email address used to find the user.
    .PARAMETER ChaosMode
        Enables random delays and failures for chaos testing.
    .PARAMETER Explain
        Shows the full help content.
    .EXAMPLE
        Get-SDUser -Id 42
    .EXAMPLE
        Get-SDUser -Email 'john.doe@example.com'
    #>
    [CmdletBinding(SupportsShouldProcess=$true, DefaultParameterSetName='ById')]
    param(
        [Parameter(Mandatory, ParameterSetName='ById')]
        [int]$Id,
        [Parameter(Mandatory, ParameterSetName='ByEmail')]
        [string]$Email,
        [switch]$ChaosMode,
        [switch]$Explain
    )

    if ($Explain) {
        Get-Help $MyInvocation.PSCommandPath -Full
        return
    }

    $target = if ($PSCmdlet.ParameterSetName -eq 'ById') { $Id } else { $Email }
    Write-STLog -Message "Get-SDUser $target" -Structured:$($env:ST_LOG_STRUCTURED -eq '1')

    if ($PSCmdlet.ParameterSetName -eq 'ById') {
        $path = "/users/$Id.json"
    }
    else {
        $encoded = [uri]::EscapeDataString($Email)
        $path = "/users.json?email=$encoded"
    }

    if ($PSCmdlet.ShouldProcess("user $target", 'Get')) {
        return Invoke-SDRequest -Method 'GET' -Path $path -ChaosMode:$ChaosMode
    }
}
