function Get-GraphSignInLogs {
    <#
    .SYNOPSIS
        Retrieves sign-in logs from Microsoft Graph.
    .DESCRIPTION
        Queries the auditLogs/signIns endpoint for a specific user and time range.
        Activity is logged and telemetry is recorded.
    .PARAMETER TenantId
        GUID identifier for the Entra ID tenant.
    .PARAMETER ClientId
        Application (client) ID used for Graph authentication.
    .PARAMETER ClientSecret
        Optional client secret for the application.
    .PARAMETER UserPrincipalName
        Optional UPN of the user to filter logs for.
    .PARAMETER StartTime
        Optional start timestamp for filtering sign-ins.
    .PARAMETER EndTime
        Optional end timestamp for filtering sign-ins.
    .EXAMPLE
        Get-GraphSignInLogs -TenantId 00000000-0000-0000-0000-000000000000 -ClientId 11111111-1111-1111-1111-111111111111 -UserPrincipalName user@contoso.com -StartTime (Get-Date).AddDays(-1) -EndTime (Get-Date)
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$TenantId,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$ClientId,
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$ClientSecret,
        [Parameter(Mandatory = $false)]
        [string]$UserPrincipalName,
        [Parameter(Mandatory = $false)]
        [datetime]$StartTime,
        [Parameter(Mandatory = $false)]
        [datetime]$EndTime
    )

    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    Write-STLog -Message "Get-GraphSignInLogs $UserPrincipalName" -Structured -Metadata @{ user = $UserPrincipalName; start = $StartTime; end = $EndTime }
    $result = 'Success'
    try {
        $token = Get-GraphAccessToken -TenantId $TenantId -ClientId $ClientId -ClientSecret $ClientSecret
        $headers = @{ Authorization = "Bearer $token" }
        $url = 'https://graph.microsoft.com/v1.0/auditLogs/signIns'
        $filterParts = @()
        if ($UserPrincipalName) { $filterParts += "userPrincipalName eq '$UserPrincipalName'" }
        if ($StartTime) { $filterParts += "createdDateTime ge ${((Get-Date $StartTime -Format 'o'))}" }
        if ($EndTime) { $filterParts += "createdDateTime le ${((Get-Date $EndTime -Format 'o'))}" }
        if ($filterParts.Count -gt 0) {
            $filter = [string]::Join(' and ', $filterParts)
            $encoded = [uri]::EscapeDataString($filter)
            $url += "?`$filter=$encoded"
        }
        $logs = Invoke-RestMethod -Uri $url -Headers $headers -Method Get
        return $logs.value
    } catch {
        $result = 'Failure'
        Write-STLog -Message "Get-GraphSignInLogs failed: $_" -Level ERROR
        throw
    } finally {
        $sw.Stop()
        Write-STTelemetryEvent -ScriptName 'Get-GraphSignInLogs' -Result $result -Duration $sw.Elapsed
    }
}
