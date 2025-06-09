function Invoke-ExchangeCalendarManager {
    <#
    .SYNOPSIS
        Manages Exchange Online calendar permissions.
    .DESCRIPTION
        Wrapper around the ExchangeCalendarManager script which ensures the
        ExchangeOnlineManagement module is installed before running.
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
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

    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $result = 'Success'
    try {
        if ($Logger) {
            Import-Module $Logger -Force -ErrorAction SilentlyContinue
        } else {
            Import-Module (Join-Path $PSScriptRoot '../../Logging/Logging.psd1') -Force -ErrorAction SilentlyContinue
        }
        if ($TelemetryClient) {
            Import-Module $TelemetryClient -Force -ErrorAction SilentlyContinue
        } else {
            Import-Module (Join-Path $PSScriptRoot '../../Telemetry/Telemetry.psd1') -Force -ErrorAction SilentlyContinue
        }
        if ($Config) {
            Import-Module $Config -Force -ErrorAction SilentlyContinue
        }

        if ($Explain) {
            Get-Help $MyInvocation.PSCommandPath -Full
            return
        }

        if ($TranscriptPath) { Start-Transcript -Path $TranscriptPath -Append | Out-Null }
        Write-STStatus -Message 'ExchangeCalendarManager launched' -Level SUCCESS -Log
        if ($Simulate) {
            Write-STStatus -Message 'Simulation mode active - no Exchange operations will occur.' -Level WARN -Log
            $mock = [pscustomobject]@{
                Simulated = $true
                Timestamp = Get-Date
            }
            return $mock
        }

    if ($PSVersionTable.PSVersion.Major -lt 7) {
        throw 'This function requires PowerShell 7 or higher.'
    }

    Write-STStatus -Message 'Checking ExchangeOnlineManagement module...' -Level SUB
    $module = Get-InstalledModule ExchangeOnlineManagement -ErrorAction SilentlyContinue
    $updateVersion = Find-Module -Name ExchangeOnlineManagement -ErrorAction SilentlyContinue

    if (-not $module) {
        Write-STStatus -Message 'Installing Exchange Online module...' -Level INFO -Log
        Install-Module -Name ExchangeOnlineManagement -Force
    } elseif ($updateVersion -and $module.Version -lt $updateVersion.Version) {
        Write-STStatus -Message 'Updating Exchange Online module...' -Level INFO -Log
        Update-Module -Name ExchangeOnlineManagement -Force
    }

    Import-Module ExchangeOnlineManagement

    try {
        Connect-ExchangeOnline -ErrorAction Stop
    } catch {
        Write-STStatus "Failed to connect to Exchange Online: $($_.Exception.Message)" -Level WARN
        return
    }

    while ($true) {
        Write-STStatus ('-' * 88) -Level INFO
        Write-STStatus -Message '1 - Grant calendar access' -Level INFO
        Write-STStatus -Message '2 - Revoke calendar access' -Level INFO
        Write-STStatus "3 - Remove user's future meetings" -Level INFO
        Write-STStatus -Message '4 - List mailbox permissions' -Level INFO
        Write-STStatus -Message 'Q - Quit' -Level INFO

        $selection = Read-Host 'Please make a selection'
        if ($selection -match '^[Qq]$') { break }

        switch ($selection) {
            '1' {
                $userCalendar = Read-Host 'Calendar owner (first.last)'
                $userRequesting = Read-Host 'Grant access to (first.last)'
                $accessRights = Read-Host 'AccessRights'
                Add-MailboxFolderPermission -Identity "${userCalendar}:\Calendar" -User $userRequesting -AccessRights $accessRights
            }
            '2' {
                $userCalendar = Read-Host 'Calendar owner (first.last)'
                $userRequesting = Read-Host 'Remove access for (first.last)'
                Remove-MailboxFolderPermission -Identity "${userCalendar}:\Calendar" -User $userRequesting -Confirm:$false
            }
            '3' {
                $userEmail = Read-Host 'User email (user@domain)'
                $daysOut = Read-Host 'Days of meetings to remove'
                Remove-CalendarEvents -Identity $userEmail -CancelOrganizedMeetings -QueryWindowInDays $daysOut
            }
            '4' {
                $userEmail = Read-Host 'User (first.last)'
                Get-Mailbox | Get-MailboxPermission -User $userEmail
            }
            default {
                Write-STStatus -Message 'Invalid selection.' -Level ERROR
            }
        }
    }

        Write-STStatus -Message 'ExchangeCalendarManager finished' -Level FINAL -Log
    } catch {
        Write-STStatus "Invoke-ExchangeCalendarManager failed: $_" -Level ERROR -Log
        Write-STLog -Message "Invoke-ExchangeCalendarManager failed: $_" -Level ERROR -Structured:$($env:ST_LOG_STRUCTURED -eq '1')
        $result = 'Failure'
        return New-STErrorObject -Message $_.Exception.Message -Category 'Exchange'
    } finally {
        if ($TranscriptPath) { Stop-Transcript | Out-Null }
        Disconnect-ExchangeOnline -Confirm:$false | Out-Null
        $sw.Stop()
        Send-STMetric -MetricName 'Invoke-ExchangeCalendarManager' -Category 'Remediation' -Value $sw.Elapsed.TotalSeconds -Details @{ Result = $result }
    }
}
