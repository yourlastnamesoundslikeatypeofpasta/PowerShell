function Get-GraphRiskySignIns {
    <#
    .SYNOPSIS
        Retrieves risky sign-in events via Microsoft Graph.
    .DESCRIPTION
        Authenticates with Microsoft Graph and queries the
        /beta/identityProtection/riskySignIns endpoint. Activity
        is logged and telemetry is recorded.
    .PARAMETER TenantId
        GUID identifier for the Entra ID tenant.
    .PARAMETER ClientId
        Application (client) ID for Graph authentication.
    .PARAMETER ClientSecret
        Optional client secret for app-only authentication.
    .EXAMPLE
        Get-GraphRiskySignIns -TenantId <tenant-id> -ClientId <app-id>
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [Alias('TenantID', 'tenantId')]
        [string]$TenantId,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ClientId,
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$ClientSecret
    )

    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    Write-STLog -Message 'Get-GraphRiskySignIns' -Structured -Metadata @{ tenant = $TenantId }
    $result = 'Success'
    try {
        $token = Get-GraphAccessToken -TenantId $TenantId -ClientId $ClientId -ClientSecret $ClientSecret
        $headers = @{ Authorization = "Bearer $token" }
        $url = 'https://graph.microsoft.com/beta/identityProtection/riskySignIns'
        $response = Invoke-STRequest -Uri $url -Headers $headers -Method 'GET'
        return $response.value
    }
    catch {
        $result = 'Failure'
        Write-STLog -Message "Get-GraphRiskySignIns failed: $_" -Level ERROR -Structured:$($env:ST_LOG_STRUCTURED -eq '1')
        throw
    }
    finally {
        $sw.Stop()
        Write-STTelemetryEvent -ScriptName 'Get-GraphRiskySignIns' -Result $result -Duration $sw.Elapsed
    }
}
