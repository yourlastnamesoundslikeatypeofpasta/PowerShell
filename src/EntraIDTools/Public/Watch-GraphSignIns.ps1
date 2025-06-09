function Watch-GraphSignIns {
    <#
    .SYNOPSIS
        Monitors sign-in logs for risky events and creates a Service Desk ticket.
    .DESCRIPTION
        Retrieves recent Entra ID sign-in logs and when any entry has a risk level
        at or above the specified threshold, a Service Desk ticket is opened using
        New-SDTicket. Activity is logged and telemetry is recorded.
    .PARAMETER Threshold
        Minimum risk level that triggers ticket creation. Valid values are Low,
        Medium and High. Default is High.
    .PARAMETER TenantId
        GUID identifier for the Entra ID tenant containing the logs.
    .PARAMETER ClientId
        Application (client) ID used for Microsoft Graph authentication.
    .PARAMETER ClientSecret
        Optional client secret for app-only authentication.
    .PARAMETER RequesterEmail
        Email address of the requester for the generated ticket.
    .PARAMETER ChaosMode
        Enable API Chaos Mode when creating the ticket.
    .EXAMPLE
        Watch-GraphSignIns -Threshold Medium -TenantId <tenant-id> -ClientId <app-id> -RequesterEmail 'secops@contoso.com'
    #>
    [CmdletBinding()]
    param(
        [Parameter()] [ValidateSet('Low','Medium','High')] [string]$Threshold = 'High',
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()] [string]$TenantId,
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()] [string]$ClientId,
        [Parameter()] [ValidateNotNullOrEmpty()] [string]$ClientSecret,
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()] [string]$RequesterEmail,
        [switch]$ChaosMode
    )

    $levelMap = @{ Low = 1; Medium = 2; High = 3 }
    $thresholdValue = $levelMap[$Threshold]

    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    Write-STLog -Message "Watch-GraphSignIns" -Structured -Metadata @{ threshold=$Threshold }
    $result = 'Success'
    try {
        $logs = Get-GraphSignInLogs -TenantId $TenantId -ClientId $ClientId -ClientSecret $ClientSecret
        $risky = $logs | Where-Object { $levelMap[$_.riskLevelAggregated] -ge $thresholdValue }
        if ($risky.Count -gt 0) {
            $subject = 'Risky sign-ins detected'
            $desc = "Detected $($risky.Count) sign-ins with risk $Threshold or higher."
            $ticket = New-SDTicket -Subject $subject -Description $desc -RequesterEmail $RequesterEmail -ChaosMode:$ChaosMode
            Write-STStatus "Created Service Desk ticket ID $($ticket.id)" -Level SUCCESS -Log
            return $ticket
        } else {
            Write-STStatus "No sign-ins exceed threshold $Threshold" -Level INFO -Log
            return $null
        }
    } catch {
        $result = 'Failure'
        Write-STLog -Message "Watch-GraphSignIns failed: $_" -Level ERROR -Structured:$($env:ST_LOG_STRUCTURED -eq '1')
        throw
    } finally {
        $sw.Stop()
        Write-STTelemetryEvent -ScriptName 'Watch-GraphSignIns' -Result $result -Duration $sw.Elapsed
    }
}
