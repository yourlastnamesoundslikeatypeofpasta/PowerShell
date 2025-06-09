function Set-SharedMailboxAutoReply {
    <#
    .SYNOPSIS
        Configures automatic replies for a shared mailbox.
    .DESCRIPTION
        Wraps a script that manages Exchange Online auto-reply settings for a
        shared mailbox. All specified parameters are forwarded to the script.
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$MailboxIdentity,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [datetime]$StartTime,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [datetime]$EndTime,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$InternalMessage,
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$ExternalMessage,
        [Parameter(Mandatory = $false)]
        [ValidateSet('None','Known','All')]
        [ValidateNotNullOrEmpty()]
        [string]$ExternalAudience = 'All',
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$AdminUser,
        [Parameter(Mandatory = $false)]
        [switch]$UseWebLogin,
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$TranscriptPath,
        [Parameter(Mandatory = $false)]
        [switch]$Simulate,
        [Parameter(Mandatory = $false)]
        [switch]$Explain,
        [Parameter(Mandatory = $false)]
        [object]$Logger,
        [Parameter(Mandatory = $false)]
        [object]$TelemetryClient,
        [Parameter(Mandatory = $false)]
        [object]$Config
    )

    try {
        if ($Logger) {
            Import-Module $Logger -Force -ErrorAction Stop
        } else {
            Import-Module (Join-Path $PSScriptRoot '../../Logging/Logging.psd1') -Force -ErrorAction Stop
        }
        if ($TelemetryClient) {
            Import-Module $TelemetryClient -Force -ErrorAction Stop
        } else {
            Import-Module (Join-Path $PSScriptRoot '../../Telemetry/Telemetry.psd1') -Force -ErrorAction Stop
        }
        if ($Config) {
            Import-Module $Config -Force -ErrorAction Stop
        }

        if ($Explain) {
            Get-Help $MyInvocation.PSCommandPath -Full
            return
        }

        if ($TranscriptPath) { Start-Transcript -Path $TranscriptPath -Append -ErrorAction Stop | Out-Null }
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        $result = 'Success'
        Write-STStatus -Message 'Running Set-SharedMailboxAutoReply' -Level SUCCESS -Log
        if ($Simulate) {
            Write-STStatus -Message 'Simulation mode active - auto-reply settings will not be changed.' -Level WARN -Log
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

    Write-STStatus -Message 'Checking ExchangeOnlineManagement module...' -Level SUB
    $module = Get-InstalledModule ExchangeOnlineManagement -ErrorAction Stop
    $updateVersion = Find-Module -Name ExchangeOnlineManagement -ErrorAction Stop

    if (-not $module) {
        Write-STStatus -Message 'Installing Exchange Online module...' -Level INFO -Log
        Install-Module -Name ExchangeOnlineManagement -Force -ErrorAction Stop
    } elseif ($updateVersion -and $module.Version -lt $updateVersion.Version) {
        Write-STStatus -Message 'Updating Exchange Online module...' -Level INFO -Log
        Update-Module -Name ExchangeOnlineManagement -Force -ErrorAction Stop
    }

    Import-Module ExchangeOnlineManagement -ErrorAction Stop

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

        Write-STStatus -Message 'Auto-reply configuration complete' -Level FINAL -Log
        return $result
    } catch {
        Write-STStatus "Set-SharedMailboxAutoReply failed: $_" -Level ERROR -Log
        Write-STLog -Message "Set-SharedMailboxAutoReply failed: $_" -Level ERROR -Structured:$($env:ST_LOG_STRUCTURED -eq '1')
        $result = 'Failure'
        throw
    } finally {
        if ($TranscriptPath) { Stop-Transcript | Out-Null }
        Disconnect-ExchangeOnline -Confirm:$false | Out-Null
        $sw.Stop()
        Send-STMetric -MetricName 'Set-SharedMailboxAutoReply' -Category 'Remediation' -Value $sw.Elapsed.TotalSeconds -Details @{ Result = $result }
    }
}
