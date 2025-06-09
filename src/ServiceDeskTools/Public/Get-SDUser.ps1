function Get-SDUser {
    <#
    .SYNOPSIS
        Retrieves details for a Service Desk user.
    .PARAMETER Id
        User ID to retrieve.
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [int]$Id,
        [switch]$ChaosMode,
        [switch]$Explain
    )

    if ($Explain) {
        Get-Help $MyInvocation.PSCommandPath -Full
        return
    }

    Write-STLog -Message "Get-SDUser $Id"
    if ($PSCmdlet.ShouldProcess("user $Id", 'Get')) {
        Invoke-SDRequest -Method 'GET' -Path "/users/$Id.json" -ChaosMode:$ChaosMode
    }
}
