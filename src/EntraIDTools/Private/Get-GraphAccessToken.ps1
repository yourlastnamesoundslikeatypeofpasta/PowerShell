function Get-GraphAccessToken {
    <#
    .SYNOPSIS
        Retrieves a Microsoft Graph access token.

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
        [switch]$DeviceLogin
    )

    if (-not $TenantId)     { $TenantId     = $env:GRAPH_TENANT_ID }
    if (-not $ClientId)     { $ClientId     = $env:GRAPH_CLIENT_ID }
    if (-not $ClientSecret) { $ClientSecret = $env:GRAPH_CLIENT_SECRET }

    if (-not $TenantId) { throw 'TenantId is required. Provide -TenantId or set GRAPH_TENANT_ID.' }
    if (-not $ClientId) { throw 'ClientId is required. Provide -ClientId or set GRAPH_CLIENT_ID.' }

    $params = @{ TenantId = $TenantId; ClientId = $ClientId; Scopes = 'https://graph.microsoft.com/.default' }
    if ($ClientSecret -and -not $DeviceLogin) { $params.ClientSecret = $ClientSecret }
    else { $params.DeviceCode = $true }

    try {
        $token = (Get-MsalToken @params -Silent -ErrorAction Stop).AccessToken
    } catch {
        $token = (Get-MsalToken @params).AccessToken
    }

    return $token
}
