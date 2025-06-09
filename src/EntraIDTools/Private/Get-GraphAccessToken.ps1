function Get-GraphAccessToken {
    <#
    .SYNOPSIS
        Retrieves a Microsoft Graph access token using MSAL caching.

    .PARAMETER DeviceLogin
        Authenticate interactively using a device code instead of a client
        secret.
    #>
    [CmdletBinding()]
    param(
        [ValidateNotNullOrEmpty()]
        [Alias('TenantID', 'tenantId')]
        [string]$TenantId,
        [ValidateNotNullOrEmpty()]
        [string]$ClientId,
        [ValidateNotNullOrEmpty()]
        [string]$ClientSecret,
        [switch]$DeviceLogin
    )

    if (-not $TenantId) { $TenantId = $env:GRAPH_TENANT_ID }
    if (-not $ClientId) { $ClientId = $env:GRAPH_CLIENT_ID }
    if (-not $ClientSecret) { $ClientSecret = $env:GRAPH_CLIENT_SECRET }

    if (-not $TenantId) { throw 'TenantId is required. Provide -TenantId or set GRAPH_TENANT_ID.' }
    if (-not $ClientId) { throw 'ClientId is required. Provide -ClientId or set GRAPH_CLIENT_ID.' }

    $params = @{ TenantId = $TenantId; ClientId = $ClientId; Scopes = 'https://graph.microsoft.com/.default' }
    if ($ClientSecret -and -not $DeviceLogin) { $params.ClientSecret = $ClientSecret }

    try {
        $tokenResponse = Get-MsalToken @params -Silent
    }
    catch {
        if ($DeviceLogin -or -not $ClientSecret) {
            $tokenResponse = Get-MsalToken @params -DeviceCode
        }
        else {
            $tokenResponse = Get-MsalToken @params
        }
    }

    return $tokenResponse.AccessToken
}
