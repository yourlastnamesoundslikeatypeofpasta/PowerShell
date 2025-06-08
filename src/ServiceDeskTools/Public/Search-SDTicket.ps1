function Search-SDTicket {
    <#
    .SYNOPSIS
        Searches Service Desk incidents by keyword.
    .PARAMETER Query
        Text used to search incident subjects and descriptions.
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Query,
        [Parameter(Mandatory = $false)]
        [switch]$ChaosMode,
        [Parameter(Mandatory = $false)]
        [switch]$Explain
    )

    if ($Explain) {
        Get-Help $MyInvocation.PSCommandPath -Full
        return
    }

    Write-STLog -Message "Search-SDTicket $Query"
    $encoded = [uri]::EscapeDataString($Query)
    if ($PSCmdlet.ShouldProcess('incidents', "Search for $Query")) {
        Invoke-SDRequest -Method 'GET' -Path "/incidents.json?search=$encoded" -ChaosMode:$ChaosMode
    }
}
