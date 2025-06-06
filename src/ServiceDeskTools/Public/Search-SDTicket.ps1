function Search-SDTicket {
    <#
    .SYNOPSIS
        Searches Service Desk incidents by keyword.
    .PARAMETER Query
        Text used to search incident subjects and descriptions.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Query,
        [switch]$ChaosMode
    )

    Write-STLog "Search-SDTicket $Query"
    $encoded = [uri]::EscapeDataString($Query)
    Invoke-SDRequest -Method 'GET' -Path "/incidents.json?search=$encoded" -ChaosMode:$ChaosMode
}
