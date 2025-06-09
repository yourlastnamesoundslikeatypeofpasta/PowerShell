function Connect-EntraID {
    <#
    .SYNOPSIS
        Connects to Microsoft Graph using stored credentials.
    .DESCRIPTION
        Retrieves GRAPH_* environment variables from a SecretManagement vault if missing
        and then calls Connect-MgGraph with the provided scopes.
    .PARAMETER Scopes
        Graph permission scopes to request. Defaults to 'User.Read.All'.
    .PARAMETER TenantId
        Entra ID tenant ID used for authentication.
    .PARAMETER ClientId
        Application (client) ID used for authentication.
    .PARAMETER ClientSecret
        Optional client secret for application authentication.
    .PARAMETER Vault
        Secret vault name to pull GRAPH_* variables from when not set.
    #>
    [CmdletBinding()]
    param(
        [string[]]$Scopes = @('User.Read.All'),
        [string]$TenantId,
        [string]$ClientId,
        [string]$ClientSecret,
        [string]$Vault
    )

    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $result = 'Success'
    try {
        Write-STStatus 'Connecting to Microsoft Graph' -Level INFO -Log

        $required = 'GRAPH_TENANT_ID','GRAPH_CLIENT_ID','GRAPH_CLIENT_SECRET'
        foreach ($name in $required) {
            if (-not $env:$name) {
                $getParams = @{ Name = $name; AsPlainText = $true; ErrorAction = 'SilentlyContinue' }
                if ($PSBoundParameters.ContainsKey('Vault')) { $getParams.Vault = $Vault }
                $val = Get-Secret @getParams
                if ($val) {
                    $env:$name = $val
                    Write-STStatus "Loaded $name from vault" -Level SUB -Log
                } else {
                    Write-STStatus "$name not found in vault" -Level WARN -Log
                }
            }
        }

        if (-not $TenantId)     { $TenantId     = $env:GRAPH_TENANT_ID }
        if (-not $ClientId)     { $ClientId     = $env:GRAPH_CLIENT_ID }
        if (-not $ClientSecret) { $ClientSecret = $env:GRAPH_CLIENT_SECRET }

        if (-not $TenantId) { throw 'TenantId is required. Provide -TenantId or set GRAPH_TENANT_ID.' }
        if (-not $ClientId) { throw 'ClientId is required. Provide -ClientId or set GRAPH_CLIENT_ID.' }

        $params = @{ TenantId = $TenantId; ClientId = $ClientId; Scopes = $Scopes; NoWelcome = $true }
        if ($ClientSecret) { $params.ClientSecret = $ClientSecret }

        Connect-MgGraph @params
        Write-STStatus -Message 'Graph connection established.' -Level SUCCESS -Log
    } catch {
        $result = 'Failure'
        Write-STFailure "Connect-EntraID failed: $_"
        throw
    } finally {
        $sw.Stop()
        Send-STMetric -MetricName 'Connect-EntraID' -Category 'Setup' -Value $sw.Elapsed.TotalSeconds -Details @{ Result = $result; Scopes = $Scopes }
    }
}
