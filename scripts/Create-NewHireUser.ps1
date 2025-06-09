<#+
.SYNOPSIS
    Creates Entra ID users when new hire Service Desk tickets are detected.
.DESCRIPTION
    Polls the Service Desk for tickets containing the phrase "new hire".
    When a ticket includes required user fields, a new account is created
    with Microsoft Graph and the ticket is marked resolved.
.PARAMETER PollMinutes
    How often to poll for new tickets in minutes. Defaults to 5.
.PARAMETER Once
    Run the check only a single time then exit.
.PARAMETER TranscriptPath
    Optional path to a transcript log file.
#>
[CmdletBinding()]
param(
    [int]$PollMinutes = 5,
    [switch]$Once,
    [string]$TranscriptPath
)

Import-Module (Join-Path $PSScriptRoot '..' 'src/Logging/Logging.psd1') -Force -ErrorAction SilentlyContinue
Import-Module (Join-Path $PSScriptRoot '..' 'src/ServiceDeskTools/ServiceDeskTools.psd1') -Force -ErrorAction SilentlyContinue

if ($TranscriptPath) { Start-Transcript -Path $TranscriptPath -Append | Out-Null }

function Get-NewHireTickets {
    Write-STStatus -Message 'Searching Service Desk for new hire tickets...' -Level INFO -Log
    Search-SDTicket -Query 'new hire'
}

function Get-UserDetailsFromTicket {
    param([object]$Ticket)
    $json = $Ticket.RawJson | ConvertFrom-Json
    [pscustomobject]@{
        FirstName        = $json.custom_fields.firstName
        LastName         = $json.custom_fields.lastName
        UserPrincipalName = $json.custom_fields.userPrincipalName
    }
}

function Create-EntraUser {
    param([object]$Details)
    if (-not (Get-Module -ListAvailable -Name Microsoft.Graph.Users)) {
        Install-Module Microsoft.Graph.Users -Scope CurrentUser -Force | Out-Null
    }
    Import-Module Microsoft.Graph.Users -ErrorAction Stop
    Connect-MgGraph -Scopes 'User.ReadWrite.All' -NoWelcome
    $params = @{ 
        DisplayName     = "$($Details.FirstName) $($Details.LastName)" 
        MailNickname    = $Details.FirstName
        UserPrincipalName = $Details.UserPrincipalName
        AccountEnabled  = $true
        PasswordProfile = @{ ForceChangePasswordNextSignIn = $true; Password = [guid]::NewGuid().ToString() }
    }
    New-MgUser @params | Out-Null
    Disconnect-MgGraph | Out-Null
    Write-STStatus "Created user $($Details.UserPrincipalName)" -Level SUCCESS -Log
}

function Start-Main {
    param([int]$PollMinutes,[switch]$Once)
    while ($true) {
        $tickets = Get-NewHireTickets
        foreach ($t in $tickets) {
            try {
                $info = Get-UserDetailsFromTicket -Ticket $t
                if (-not $info.FirstName -or -not $info.LastName -or -not $info.UserPrincipalName) {
                    Write-STStatus "Ticket $($t.Id) missing user fields" -Level WARN -Log
                    continue
                }
                Create-EntraUser -Details $info
                Set-SDTicket -Id $t.Id -Fields @{ state = 'Resolved' } | Out-Null
                Write-STStatus "Resolved ticket $($t.Id)" -Level SUCCESS -Log
            } catch {
                Write-STStatus "Failed processing ticket $($t.Id): $_" -Level ERROR -Log
            }
        }
        if ($Once) { break }
        Start-Sleep -Seconds ($PollMinutes * 60)
    }
}

try {
    Start-Main -PollMinutes $PollMinutes -Once:$Once
} finally {
    if ($TranscriptPath) { Stop-Transcript | Out-Null }
}

