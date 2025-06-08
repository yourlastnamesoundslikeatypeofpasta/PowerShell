<#+
.SYNOPSIS
    Caches Service Desk tickets locally and polls for new ones.
.DESCRIPTION
    Retrieves all tickets on first run and saves them to a JSON file.
    Continues polling the API for new tickets and appends them to the cache.
    Performs a full refresh of the cache every 24 hours by default.
.PARAMETER CachePath
    Path to the JSON file used for storing ticket data.
.PARAMETER PollMinutes
    How often to poll for new tickets in minutes. Defaults to 5.
.PARAMETER FullSyncHours
    Interval between full synchronizations in hours. Defaults to 24.
#>
param(
    [string]$CachePath = "$PSScriptRoot/../config/ticketCache.json",
    [int]$PollMinutes = 5,
    [int]$FullSyncHours = 24
)

Import-Module (Join-Path $PSScriptRoot '..' 'src/Logging/Logging.psd1') -ErrorAction SilentlyContinue
Import-Module (Join-Path $PSScriptRoot '..' 'src/ServiceDeskTools/ServiceDeskTools.psd1') -ErrorAction SilentlyContinue

function Get-AllTickets {
    Write-STStatus 'Retrieving all tickets...' -Level INFO -Log
    Invoke-SDRequest -Method 'GET' -Path '/incidents.json?per_page=100'
}

function Get-NewTickets {
    param([datetime]$Since)
    $param = [uri]::EscapeDataString($Since.ToString('o'))
    Write-STStatus "Checking for new tickets since $Since" -Level SUB -Log
    Invoke-SDRequest -Method 'GET' -Path "/incidents.json?created_after=$param"
}

if (-not (Test-Path $CachePath)) {
    $all = Get-AllTickets
    $state = @{ lastFullSync = (Get-Date).ToString('o'); tickets = $all }
    $state | ConvertTo-Json -Depth 10 | Out-File -FilePath $CachePath -Encoding utf8
}

$cache = Get-Content $CachePath -Raw | ConvertFrom-Json
$lastFullSync = [datetime]$cache.lastFullSync
$tickets = [System.Collections.Generic.List[object]]::new()
if ($cache.tickets) { $tickets.AddRange($cache.tickets) }

while ($true) {
    if ((Get-Date) -gt $lastFullSync.AddHours($FullSyncHours)) {
        Write-STStatus 'Running full ticket sync...' -Level INFO -Log
        $tickets = Get-AllTickets
        $lastFullSync = Get-Date
    } else {
        $latest = ($tickets | Sort-Object created_at | Select-Object -Last 1).created_at
        if ($latest) {
            $new = Get-NewTickets -Since ([datetime]$latest)
            if ($new) {
                $tickets.AddRange($new)
                Write-STStatus "Added $($new.Count) new tickets to cache." -Level SUCCESS -Log
            } else {
                Write-STStatus 'No new tickets found.' -Level SUB -Log
            }
        }
    }
    $cache = @{ lastFullSync = $lastFullSync.ToString('o'); tickets = $tickets }
    $cache | ConvertTo-Json -Depth 10 | Out-File -FilePath $CachePath -Encoding utf8
    Start-Sleep -Seconds ($PollMinutes * 60)
}
