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
        [switch]$EnableTranscript
    )

    Write-Host '[***] Running Set-SharedMailboxAutoReply' -ForegroundColor Green -BackgroundColor Black
    if ($EnableTranscript -or $TranscriptPath) {
        if (-not $TranscriptPath) {
            $TranscriptPath = Join-Path $env:USERPROFILE "Set-SharedMailboxAutoReply_$(Get-Date -Format yyyyMMdd_HHmmss).log"
        }
        try { Start-Transcript -Path $TranscriptPath -Append | Out-Null } catch { Write-Warning "Failed to start transcript: $_" }
    }

    if (-not $ExternalMessage) { $ExternalMessage = $InternalMessage }

    Write-Verbose 'Checking ExchangeOnlineManagement module...'
    $module = Get-InstalledModule ExchangeOnlineManagement -ErrorAction SilentlyContinue
    $updateVersion = Find-Module -Name ExchangeOnlineManagement -ErrorAction SilentlyContinue

    if (-not $module) {
        Write-Host 'Installing Exchange Online module...'
        Install-Module -Name ExchangeOnlineManagement -Force
    } elseif ($updateVersion -and $module.Version -lt $updateVersion.Version) {
        Write-Host 'Updating Exchange Online module...'
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

    Write-Host '[***] Auto-reply configuration complete' -ForegroundColor Green -BackgroundColor Black
    if ($EnableTranscript -or $TranscriptPath) {
        try { Stop-Transcript | Out-Null } catch {}
        Write-Host "[***] Transcript saved to $TranscriptPath" -ForegroundColor DarkGreen -BackgroundColor Black
    }

    return $result
}
