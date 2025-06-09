# Original name: Watch-GraphSignIns
function Monitor-GraphSignIn {
    <#
    .SYNOPSIS
        Monitor sign-in logs and create Service Desk tickets when risky events are detected.
    .DESCRIPTION
        Combines Get-GraphSignInLogs with New-SDTicket. Sign-ins with a risk level
        equal to or above the specified threshold trigger ticket creation.
        Activity is logged and chaos testing can be enabled.
    .PARAMETER UserPrincipalName
        Optional UPN to filter the sign-in logs.
    .PARAMETER StartTime
        Optional start time for the query. Defaults to one hour ago.
    .PARAMETER EndTime
        Optional end time for the query. Defaults to now.
    .PARAMETER TenantId
        GUID identifier for the Entra ID tenant.
    .PARAMETER ClientId
        Application (client) ID used for Microsoft Graph authentication.
    .PARAMETER ClientSecret
        Optional client secret for app-only authentication.
    .PARAMETER RequesterEmail
        Email address used when creating Service Desk tickets.
    .PARAMETER Threshold
        Minimum risk level that triggers ticket creation. Low < Medium < High.
    .PARAMETER ChaosMode
        Enable chaos testing during ticket creation.
    .EXAMPLE
        Monitor-GraphSignIn -TenantId <tenant> -ClientId <app> -RequesterEmail 'admin@example.com'
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [string]$UserPrincipalName,
        [datetime]$StartTime = (Get-Date).AddHours(-1),
        [datetime]$EndTime = (Get-Date),
        [Parameter(Mandatory)]
        [string]$TenantId,
        [Parameter(Mandatory)]
        [string]$ClientId,
        [string]$ClientSecret,
        [Parameter(Mandatory)]
        [string]$RequesterEmail,
        [ValidateSet('Low','Medium','High')]
        [string]$Threshold = 'High',
        [switch]$ChaosMode,
        [switch]$Explain
    )

    if ($Explain) { Get-Help $MyInvocation.PSCommandPath -Full; return }

    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    Write-STLog -Message 'Monitor-GraphSignIn' -Structured -Metadata @{ threshold=$Threshold }
    $result = 'Success'
    try {
        $logs = Get-GraphSignInLogs -UserPrincipalName $UserPrincipalName -StartTime $StartTime -EndTime $EndTime -TenantId $TenantId -ClientId $ClientId -ClientSecret $ClientSecret
        if (-not $logs) { return }
        $order = @{ low = 1; medium = 2; high = 3 }
        $threshVal = $order[$Threshold.ToLower()]
        foreach ($log in $logs) {
            $risk = $log.riskLevelAggregated
            if ($order[$risk.ToLower()] -ge $threshVal) {
                $subject = "Risky sign-in for $($log.userPrincipalName)"
                $desc = "Risk level $risk from IP $($log.ipAddress) at $($log.createdDateTime)"
                if ($PSCmdlet.ShouldProcess($subject, 'Create Ticket')) {
                    New-SDTicket -Subject $subject -Description $desc -RequesterEmail $RequesterEmail -ChaosMode:$ChaosMode | Out-Null
                }
            }
        }
        return $logs
    } catch {
        $result = 'Failure'
        Write-STLog -Message "Monitor-GraphSignIn failed: $_" -Level ERROR
        throw
    } finally {
        $sw.Stop()
        Write-STTelemetryEvent -ScriptName 'Monitor-GraphSignIn' -Result $result -Duration $sw.Elapsed
    }
}
