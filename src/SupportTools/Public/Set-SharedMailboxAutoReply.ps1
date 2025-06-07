function Set-SharedMailboxAutoReply {
    <#
    .SYNOPSIS
        Configures automatic replies for a shared mailbox.
    .DESCRIPTION
        Wraps a script that manages Exchange Online auto-reply settings for a
        shared mailbox. All specified parameters are forwarded to the script.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$MailboxIdentity,
        [Parameter(Mandatory)]
        [datetime]$StartTime,
        [Parameter(Mandatory)]
        [datetime]$EndTime,
        [Parameter(Mandatory)]
        [string]$InternalMessage,
        [string]$ExternalMessage,
        [ValidateSet('None','Known','All')]
        [string]$ExternalAudience = 'All',
        [Parameter(Mandatory)]
        [string]$AdminUser,
        [switch]$UseWebLogin,
        [string]$TranscriptPath,
        [switch]$Simulate,
        [switch]$Explain,
        [object]$Logger,
        [object]$TelemetryClient,
        [object]$Config
    )

    try {
        if ($Logger) {
            Import-Module $Logger -ErrorAction SilentlyContinue
        } else {
            Import-Module (Join-Path $PSScriptRoot '../../Logging/Logging.psd1') -ErrorAction SilentlyContinue
        }
        if ($TelemetryClient) {
            Import-Module $TelemetryClient -ErrorAction SilentlyContinue
        } else {
            Import-Module (Join-Path $PSScriptRoot '../../Telemetry/Telemetry.psd1') -ErrorAction SilentlyContinue
        }
        if ($Config) {
            Import-Module $Config -ErrorAction SilentlyContinue
        }

        if ($Explain) {
            Get-Help $MyInvocation.PSCommandPath -Full
            return
        }

        if ($TranscriptPath) { Start-Transcript -Path $TranscriptPath -Append | Out-Null }
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        $result = 'Success'
        Write-STStatus 'Running Set-SharedMailboxAutoReply' -Level SUCCESS -Log
        if ($Simulate) {
            Write-STStatus 'Simulation mode active - auto-reply settings will not be changed.' -Level WARN -Log
            $mock = [pscustomobject]@{
                MailboxIdentity = $MailboxIdentity
                Simulated       = $true
                Timestamp       = Get-Date
            }
            return $mock
        }

    if ([string]::IsNullOrWhiteSpace($ExternalMessage)) {
        $ExternalMessage = $InternalMessage
    }

    Write-STStatus 'Checking ExchangeOnlineManagement module...' -Level SUB
    $module = Get-InstalledModule ExchangeOnlineManagement -ErrorAction SilentlyContinue
    $updateVersion = Find-Module -Name ExchangeOnlineManagement -ErrorAction SilentlyContinue

    if (-not $module) {
        Write-STStatus 'Installing Exchange Online module...' -Level INFO -Log
        Install-Module -Name ExchangeOnlineManagement -Force
    } elseif ($updateVersion -and $module.Version -lt $updateVersion.Version) {
        Write-STStatus 'Updating Exchange Online module...' -Level INFO -Log
        Update-Module -Name ExchangeOnlineManagement -Force
    }

    Import-Module ExchangeOnlineManagement

    try {
        if ($UseWebLogin) {
            Connect-ExchangeOnline -UserPrincipalName $AdminUser -UseWebLogin -ErrorAction Stop
        } else {
            Connect-ExchangeOnline -UserPrincipalName $AdminUser -ErrorAction Stop
        }
    } catch {
        throw "Failed to connect to Exchange Online: $($_.Exception.Message)"
    }

    Set-MailboxAutoReplyConfiguration -Identity $MailboxIdentity `
        -AutoReplyState Scheduled `
        -StartTime $StartTime `
        -EndTime $EndTime `
        -InternalMessage $InternalMessage `
        -ExternalMessage $ExternalMessage `
        -ExternalAudience $ExternalAudience

    $result = Get-MailboxAutoReplyConfiguration -Identity $MailboxIdentity

        Disconnect-ExchangeOnline -Confirm:$false

        Write-STStatus 'Auto-reply configuration complete' -Level FINAL -Log
        return $result
    } catch {
        Write-STStatus "Set-SharedMailboxAutoReply failed: $_" -Level ERROR -Log
        Write-STLog -Message "Set-SharedMailboxAutoReply failed: $_" -Level ERROR
        $result = 'Failure'
        return New-STErrorObject -Message $_.Exception.Message -Category 'Exchange'
    } finally {
        if ($TranscriptPath) { Stop-Transcript | Out-Null }
        Disconnect-ExchangeOnline -Confirm:$false | Out-Null
        $sw.Stop()
        Send-STMetric -MetricName 'Set-SharedMailboxAutoReply' -Category 'Remediation' -Value $sw.Elapsed.TotalSeconds -Details @{ Result = $result }
    }
}
