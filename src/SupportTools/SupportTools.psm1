function Invoke-ScriptFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name,
        [Parameter(ValueFromRemainingArguments=$true)]
        [object[]]$Args
    )
    $path = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath '..' | Join-Path -ChildPath "scripts/$Name"
    if (-not (Test-Path $path)) { throw "Script '$Name' not found." }
    & $path @Args
}

function AddUsersToGroup {
    [CmdletBinding()]
    param(
        [string]$CsvPath,
        [string]$GroupName
    )

    $arguments = @()
    if ($PSBoundParameters.ContainsKey('CsvPath')) {
        $arguments += '-CsvPath'
        $arguments += $CsvPath
    }
    if ($PSBoundParameters.ContainsKey('GroupName')) {
        $arguments += '-GroupName'
        $arguments += $GroupName
    }

    Invoke-ScriptFile -Name 'AddUsersToGroup.ps1' -Args $arguments
}

function CleanupArchive {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [object[]]$Arguments
    )
    Invoke-ScriptFile -Name "CleanupArchive.ps1" -Args $Arguments
}

function Convert-ExcelToCsv {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [object[]]$Arguments
    )
    Invoke-ScriptFile -Name "Convert-ExcelToCsv.ps1" -Args $Arguments
}

function Get-CommonSystemInfo {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [object[]]$Arguments
    )
    Invoke-ScriptFile -Name "Get-CommonSystemInfo.ps1" -Args $Arguments
}

function Get-FailedLogins {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [object[]]$Arguments
    )
    Invoke-ScriptFile -Name "Get-FailedLogins.ps1" -Args $Arguments
}

function Get-NetworkShares {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [object[]]$Arguments
    )
    Invoke-ScriptFile -Name "Get-NetworkShares.ps1" -Args $Arguments
}

function Get-UniquePermissions {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [object[]]$Arguments
    )
    Invoke-ScriptFile -Name "Get-UniquePermissions.ps1" -Args $Arguments
}

function Install-Fonts {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [object[]]$Arguments
    )
    Invoke-ScriptFile -Name "Install-Fonts.ps1" -Args $Arguments
}

function PostInstallScript {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [object[]]$Arguments
    )
    Invoke-ScriptFile -Name "PostInstallScript.ps1" -Args $Arguments
}

function ProductKey {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [object[]]$Arguments
    )
    Invoke-ScriptFile -Name "ProductKey.ps1" -Args $Arguments
}

function Invoke-DeploymentTemplate {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [object[]]$Arguments
    )
    Invoke-ScriptFile -Name "SS_DEPLOYMENT_TEMPLATE.ps1" -Args $Arguments
}

function Search-ReadMe {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [object[]]$Arguments
    )
    Invoke-ScriptFile -Name "Search-ReadMe.ps1" -Args $Arguments
}

function Set-ComputerIPAddress {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [object[]]$Arguments
    )
    Invoke-ScriptFile -Name "Set-ComputerIPAddress.ps1" -Args $Arguments
}

function Set-NetAdapterMetering {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [object[]]$Arguments
    )
    Invoke-ScriptFile -Name "Set-NetAdapterMetering.ps1" -Args $Arguments
}

function Set-TimeZoneEasternStandardTime {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [object[]]$Arguments
    )
    Invoke-ScriptFile -Name "Set-TimeZoneEasternStandardTime.ps1" -Args $Arguments
}

function SimpleCountdown {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [object[]]$Arguments
    )
    Invoke-ScriptFile -Name "SimpleCountdown.ps1" -Args $Arguments
}

function Update-Sysmon {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [object[]]$Arguments
    )
    Invoke-ScriptFile -Name "Update-Sysmon.ps1" -Args $Arguments
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
                Add-MailboxFolderPermission -Identity "$userCalendar:\Calendar" -User $userRequesting -AccessRights $accessRights
            }
            '2' {
                $userCalendar = Read-Host 'Calendar owner (first.last)'
                $userRequesting = Read-Host 'Remove access for (first.last)'
                Remove-MailboxFolderPermission -Identity "$userCalendar:\Calendar" -User $userRequesting -Confirm:$false
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



Export-ModuleMember -Function 'AddUsersToGroup','CleanupArchive','Convert-ExcelToCsv','Get-CommonSystemInfo','Get-FailedLogins','Get-NetworkShares','Get-UniquePermissions','Install-Fonts','PostInstallScript','ProductKey','Invoke-DeploymentTemplate','Search-ReadMe','Set-ComputerIPAddress','Set-NetAdapterMetering','Set-TimeZoneEasternStandardTime','SimpleCountdown','Update-Sysmon','Invoke-ExchangeCalendarManager'
