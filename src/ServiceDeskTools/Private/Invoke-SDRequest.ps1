function Invoke-SDRequest {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Method,
        [Parameter(Mandatory)][string]$Path,
        [hashtable]$Body,
        [switch]$ChaosMode,
        [string]$BaseUri,
        [string]$Vault
    )
    Assert-ParameterNotNull $Method 'Method'
    Assert-ParameterNotNull $Path 'Path'

    $baseUri = if ($BaseUri) { $BaseUri } else { $env:SD_BASE_URI }
    if (-not $baseUri) { $baseUri = 'https://api.samanage.com' }

    $params = @{ Name = 'SD_API_TOKEN'; Required = $true }
    if ($PSBoundParameters.ContainsKey('Vault')) { $params.Vault = $Vault }
    $token = Get-STSecret @params

    $rateLimit = if ($env:SD_RATE_LIMIT_PER_MINUTE) { [int]$env:SD_RATE_LIMIT_PER_MINUTE } else { $null }
    Wait-SDRateLimit -RateLimit $rateLimit

    $headers = @{ 'X-Samanage-Authorization' = "Bearer $token"; Accept = 'application/json' }
    $uri = $baseUri.TrimEnd('/') + $Path
    Write-STLog -Message "SDRequest $Method $uri"
    Write-Verbose "Invoking $Method $uri"
    Invoke-SDRestWithRetry -Method $Method -Uri $uri -Headers $headers -Body $Body -ChaosMode:$ChaosMode
}
