$publicDir = Join-Path $PSScriptRoot 'Public'
if (Test-Path $publicDir) {
    Get-ChildItem -Path $publicDir -Filter '*.ps1' | ForEach-Object { . $_.FullName }
}
$privateDir = Join-Path $PSScriptRoot 'Private'
if (Test-Path $privateDir) {
    Get-ChildItem -Path $privateDir -Filter '*.ps1' | ForEach-Object { . $_.FullName }
}

function Set-SharedMailboxAutoReply {
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
        [switch]$UseWebLogin
    )

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

    return $result
}

function Invoke-ExchangeCalendarManager {
    [CmdletBinding()]
    param()

    if ($PSVersionTable.PSVersion.Major -lt 7) {
        throw 'This function requires PowerShell 7 or higher.'
    }

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
        Connect-ExchangeOnline -ErrorAction Stop
    } catch {
        Write-Warning "Failed to connect to Exchange Online: $($_.Exception.Message)"
        return
    }

    while ($true) {
        Write-Host ('-' * 88) -ForegroundColor Yellow
        Write-Host "1 - Grant calendar access" -ForegroundColor Yellow
        Write-Host "2 - Revoke calendar access" -ForegroundColor Yellow
        Write-Host "3 - Remove user's future meetings" -ForegroundColor Yellow
        Write-Host "4 - List mailbox permissions" -ForegroundColor Yellow
        Write-Host "Q - Quit" -ForegroundColor Yellow

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
                Write-Host 'Invalid selection.' -ForegroundColor Red
            }
        }
    }

    Disconnect-ExchangeOnline -Confirm:$false
}



Export-ModuleMember -Function 'Add-UsersToGroup','CleanupArchive','Convert-ExcelToCsv','Get-CommonSystemInfo','Get-FailedLogins','Get-NetworkShares','Get-UniquePermissions','Install-Fonts','PostInstallScript','ProductKey','Invoke-DeploymentTemplate','Search-ReadMe','Set-ComputerIPAddress','Set-NetAdapterMetering','Set-TimeZoneEasternStandardTime','SimpleCountdown','Update-Sysmon','Set-SharedMailboxAutoReply','Invoke-ExchangeCalendarManager'
