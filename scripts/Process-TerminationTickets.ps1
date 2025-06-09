<#+
.SYNOPSIS
    Disable users automatically for termination tickets.
.DESCRIPTION
    Searches Service Desk for open tickets containing the word "termination" and
    disables the referenced user account using Disable-GraphUser. Processed
    ticket IDs are stored in a JSON file to avoid duplicate actions.
.PARAMETER PollMinutes
    How often to poll for new tickets. Defaults to 5 minutes.
.PARAMETER StatePath
    Path to the JSON file tracking processed ticket IDs.
.PARAMETER TenantId
    Azure AD tenant ID used when disabling accounts.
.PARAMETER ClientId
    Application ID for Microsoft Graph authentication.
.PARAMETER ClientSecret
    Optional client secret for Graph authentication.
#>
param(
    [int]$PollMinutes = 5,
    [string]$StatePath = "$PSScriptRoot/../config/terminated.json",
    [string]$TenantId = $env:GRAPH_TENANT_ID,
    [string]$ClientId = $env:GRAPH_CLIENT_ID,
    [string]$ClientSecret = $env:GRAPH_CLIENT_SECRET
)

Import-Module (Join-Path $PSScriptRoot '..' 'src/Logging/Logging.psd1') -Force -ErrorAction SilentlyContinue
Import-Module (Join-Path $PSScriptRoot '..' 'src/ServiceDeskTools/ServiceDeskTools.psd1') -Force -ErrorAction SilentlyContinue
Import-Module (Join-Path $PSScriptRoot '..' 'src/EntraIDTools/EntraIDTools.psd1') -Force -ErrorAction SilentlyContinue

if (Test-Path $StatePath) { $processed = Get-Content $StatePath | ConvertFrom-Json } else { $processed = @() }

while ($true) {
    Write-STStatus -Message 'Searching for termination tickets...' -Level INFO -Log
    $tickets = Search-SDTicket -Query 'termination'
    foreach ($t in $tickets) {
        if ($processed -contains $t.Id) { continue }
        $upn = $null
        $pattern = '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+'
        if ($t.Title -match $pattern) { $upn = $Matches[0] }
        elseif ($t.RawJson -match $pattern) { $upn = $Matches[0] }
        if ($upn) {
            Write-STStatus "Disabling user $upn (ticket $($t.Id))" -Level INFO -Log
            Disable-GraphUser -UserPrincipalName $upn -TenantId $TenantId -ClientId $ClientId -ClientSecret $ClientSecret
            $processed += $t.Id
        } else {
            Write-STStatus "Ticket $($t.Id) missing user info" -Level WARN -Log
        }
    }
    $processed | ConvertTo-Json | Out-File -FilePath $StatePath -Encoding utf8
    Start-Sleep -Seconds ($PollMinutes * 60)
}
