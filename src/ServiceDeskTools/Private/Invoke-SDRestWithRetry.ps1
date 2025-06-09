function Invoke-SDRestWithRetry {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Method,
        [Parameter(Mandatory)][string]$Uri,
        [hashtable]$Headers,
        $Body,
        [switch]$ChaosMode
    )

    Invoke-STRequest -Method $Method -Uri $Uri -Headers $Headers -Body $Body -ChaosMode:$ChaosMode
}
