function Get-GraphAccessToken {
    <#
    .SYNOPSIS
        Retrieves and caches a Microsoft Graph access token.

    .PARAMETER DeviceLogin
        Authenticate interactively using a device code instead of a client
        secret.
    #>
    [CmdletBinding()]
    param(
        [ValidateNotNullOrEmpty()]
        [Alias('TenantID','tenantId')]
        [string]$TenantId,
        [ValidateNotNullOrEmpty()]
        [string]$ClientId,
        [ValidateNotNullOrEmpty()]
        [string]$ClientSecret,
        [switch]$DeviceLogin,
        [ValidateNotNullOrEmpty()]
        [string]$CachePath = "$env:USERPROFILE/.graphToken.json"
    )

    if (-not $TenantId)     { $TenantId     = $env:GRAPH_TENANT_ID }
    if (-not $ClientId)     { $ClientId     = $env:GRAPH_CLIENT_ID }
    if (-not $ClientSecret) { $ClientSecret = $env:GRAPH_CLIENT_SECRET }

    if (-not $TenantId) { throw 'TenantId is required. Provide -TenantId or set GRAPH_TENANT_ID.' }
    if (-not $ClientId) { throw 'ClientId is required. Provide -ClientId or set GRAPH_CLIENT_ID.' }
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
    if ($ClientSecret -and -not $DeviceLogin) { $params.ClientSecret = $ClientSecret }
    else { $params.DeviceCode = $true }

    $tokenResponse = Get-MsalToken @params
    $cache = @{ accessToken = $tokenResponse.AccessToken; expiresOn = $tokenResponse.ExpiresOn }
    $cache | ConvertTo-Json | Out-File -FilePath $CachePath -Encoding utf8
    return $tokenResponse.AccessToken
}
