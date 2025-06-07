function Get-GraphAccessToken {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$TenantId,
        [Parameter(Mandatory)][string]$ClientId,
        [string]$ClientSecret,
        [string]$CachePath = "$env:USERPROFILE/.graphToken.json"
    )
    if (Test-Path $CachePath) {
        try {
            $cache = Get-Content $CachePath | ConvertFrom-Json
            $expiry = [datetime]$cache.expiresOn
            if ($expiry -gt (Get-Date).AddMinutes(5)) {
                return $cache.accessToken
            }
        } catch {}
    }

    $params = @{ TenantId = $TenantId; ClientId = $ClientId; Scopes = 'https://graph.microsoft.com/.default' }
    if ($ClientSecret) { $params.ClientSecret = $ClientSecret }
    else { $params.DeviceCode = $true }

    $tokenResponse = Get-MsalToken @params
    $cache = @{ accessToken = $tokenResponse.AccessToken; expiresOn = $tokenResponse.ExpiresOn }
    $cache | ConvertTo-Json | Out-File -FilePath $CachePath -Encoding utf8
    return $tokenResponse.AccessToken
}
