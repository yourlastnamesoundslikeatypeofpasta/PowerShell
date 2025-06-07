function Invoke-ExchangeCalendarManager {
    <#
    .SYNOPSIS
        Manages Exchange Online calendar permissions.
    .DESCRIPTION
        Wrapper around the ExchangeCalendarManager script which ensures the
        ExchangeOnlineManagement module is installed before running.
    #>
    [CmdletBinding()]
    param(
        [string]$TranscriptPath,
        [switch]$Simulate,
        [switch]$Explain
    )

    if ($Explain) {
        Get-Help $MyInvocation.PSCommandPath -Full
        return
    }

    Import-Module (Join-Path $PSScriptRoot '../../Telemetry/Telemetry.psd1') -ErrorAction SilentlyContinue
    $operationId = [guid]::NewGuid().Guid
    $sw = [System.Diagnostics.Stopwatch]::StartNew()

    if ($TranscriptPath) { Start-Transcript -Path $TranscriptPath -Append | Out-Null }
    Write-STStatus 'ExchangeCalendarManager launched' -Level SUCCESS -Log
    if ($Simulate) {
        Write-STStatus 'Simulation mode active - no Exchange operations will occur.' -Level WARN -Log
        $mock = [pscustomobject]@{
            Simulated = $true
            Timestamp = Get-Date
        }
        if ($TranscriptPath) { Stop-Transcript | Out-Null }
        return $mock
    }

    if ($PSVersionTable.PSVersion.Major -lt 7) {
        throw 'This function requires PowerShell 7 or higher.'
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
        Connect-ExchangeOnline -ErrorAction Stop
    } catch {
        Write-STStatus "Failed to connect to Exchange Online: $($_.Exception.Message)" -Level WARN
        return
    }

    try {
        while ($true) {
        Write-STStatus ('-' * 88) -Level INFO
        Write-STStatus '1 - Grant calendar access' -Level INFO
        Write-STStatus '2 - Revoke calendar access' -Level INFO
        Write-STStatus "3 - Remove user's future meetings" -Level INFO
        Write-STStatus '4 - List mailbox permissions' -Level INFO
        Write-STStatus 'Q - Quit' -Level INFO

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
                Write-STStatus 'Invalid selection.' -Level ERROR
            }
        }
    }

    Disconnect-ExchangeOnline -Confirm:$false

    Write-STStatus 'ExchangeCalendarManager finished' -Level FINAL -Log
    } finally {
        $sw.Stop()
        Send-STMetric -MetricName 'Invoke-ExchangeCalendarManager' -Category 'Remediation' -Value $sw.Elapsed.TotalSeconds -OperationId $operationId
        if ($TranscriptPath) { Stop-Transcript | Out-Null }
    }
}
