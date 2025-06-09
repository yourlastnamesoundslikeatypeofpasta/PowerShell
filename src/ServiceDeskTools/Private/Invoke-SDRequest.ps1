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

    $token = $env:SD_API_TOKEN
    if (-not $token) {
        $getParams = @{ Name = 'SD_API_TOKEN'; AsPlainText = $true; ErrorAction = 'SilentlyContinue' }
        if ($PSBoundParameters.ContainsKey('Vault')) { $getParams.Vault = $Vault }
        $token = Get-Secret @getParams
        if ($token) { $env:SD_API_TOKEN = $token } else { throw 'SD_API_TOKEN environment variable must be set.' }
    }

    $rateLimit = if ($env:SD_RATE_LIMIT_PER_MINUTE) { [int]$env:SD_RATE_LIMIT_PER_MINUTE } else { $null }
    Wait-SDRateLimit -RateLimit $rateLimit

    $headers = @{ 'X-Samanage-Authorization' = "Bearer $token"; Accept = 'application/json' }
    $uri = $baseUri.TrimEnd('/') + $Path
    Write-STLog -Message "SDRequest $Method $uri"
    Write-Verbose "Invoking $Method $uri"
    Invoke-SDRestWithRetry -Method $Method -Uri $uri -Headers $headers -Body $Body -ChaosMode:$ChaosMode
}
