function Get-GraphSignInLogs {
    <#
    .SYNOPSIS
        Retrieves Entra ID sign-in logs via Microsoft Graph.
    .DESCRIPTION
        Authenticates with Microsoft Graph and returns sign-in events. Logs are
        filtered by optional user principal name and start/end timestamps. All
        activity is logged and telemetry is recorded.
    .PARAMETER UserPrincipalName
        Optional UPN to filter the logs.
    .PARAMETER StartTime
        Optional start of the time range (inclusive).
    .PARAMETER EndTime
        Optional end of the time range (inclusive).
    .PARAMETER TenantId
        GUID identifier for the Entra ID tenant.
    .PARAMETER ClientId
        Application (client) ID used for Graph authentication.
    .PARAMETER ClientSecret
        Optional client secret for app-only authentication.
    .EXAMPLE
        Get-GraphSignInLogs -UserPrincipalName user@contoso.com -StartTime (Get-Date).AddDays(-1) -TenantId <tenant> -ClientId <app>
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$UserPrincipalName,
        [Parameter()]
        [datetime]$StartTime,
        [Parameter()]
        [datetime]$EndTime,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$TenantId,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ClientId,
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$ClientSecret
    )

    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    Write-STLog -Message "Get-GraphSignInLogs" -Structured -Metadata @{ user = $UserPrincipalName; start = $StartTime; end = $EndTime }
    $result = 'Success'
    try {
        $token = Get-GraphAccessToken -TenantId $TenantId -ClientId $ClientId -ClientSecret $ClientSecret
        $headers = @{ Authorization = "Bearer $token" }
        $filterParts = @()
        if ($UserPrincipalName) { $filterParts += "userPrincipalName eq '$UserPrincipalName'" }
        if ($StartTime) { $filterParts += "createdDateTime ge $($StartTime.ToString('o'))" }
        if ($EndTime) { $filterParts += "createdDateTime le $($EndTime.ToString('o'))" }
        $uri = 'https://graph.microsoft.com/v1.0/auditLogs/signIns'
        if ($filterParts.Count -gt 0) {
            $filter = [string]::Join(' and ', $filterParts)
            $uri += "?`$filter=" + [System.Web.HttpUtility]::UrlEncode($filter)
        }
        $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get
        return $response.value
    }
    catch {
        $result = 'Failure'
        Write-STLog -Message "Get-GraphSignInLogs failed: $_" -Level ERROR
        throw
    }
    finally {
        $sw.Stop()
        Write-STTelemetryEvent -ScriptName 'Get-GraphSignInLogs' -Result $result -Duration $sw.Elapsed
    }
}
