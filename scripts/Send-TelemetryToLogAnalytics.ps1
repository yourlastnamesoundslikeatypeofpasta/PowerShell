<#
.SYNOPSIS
    Sends SupportTools telemetry to an Azure Monitor Log Analytics workspace.
.DESCRIPTION
    Reads telemetry events produced by Write-STTelemetryEvent and forwards them
    to Log Analytics using the HTTP Data Collector API.
.PARAMETER WorkspaceId
    The Log Analytics workspace ID.
.PARAMETER WorkspaceKey
    The primary or secondary key for the workspace.
.PARAMETER Vault
    Secret vault name to pull WorkspaceId and WorkspaceKey from when they are
    not provided.
.EXAMPLE
    ./Send-TelemetryToLogAnalytics.ps1 -WorkspaceId "<id>" -WorkspaceKey "<key>"
.EXAMPLE
    ./Send-TelemetryToLogAnalytics.ps1 -Vault "CompanyVault"
.NOTES
    Telemetry is only sent when ST_ENABLE_TELEMETRY=1.
#>
[CmdletBinding()]
param(
    [string]$WorkspaceId,

    [string]$WorkspaceKey,

    [string]$Vault
)

Import-Module (Join-Path $PSScriptRoot '..' 'src/Logging/Logging.psd1') -ErrorAction SilentlyContinue
Import-Module (Join-Path $PSScriptRoot '..' 'src/Telemetry/Telemetry.psd1') -ErrorAction SilentlyContinue

if ($env:ST_ENABLE_TELEMETRY -ne '1') {
    Write-STStatus -Message 'ST_ENABLE_TELEMETRY is not set. Telemetry will not be sent.' -Level WARN
    return
}

# Load secrets when parameters missing
if (-not $WorkspaceId) {
    $getParams = @{ Name = 'WorkspaceId'; AsPlainText = $true; ErrorAction = 'SilentlyContinue' }
    if ($PSBoundParameters.ContainsKey('Vault')) { $getParams.Vault = $Vault }
    $val = Get-Secret @getParams
    if ($val) {
        $WorkspaceId = $val
        Write-STStatus 'Loaded WorkspaceId from vault' -Level SUB -Log
    } else {
        Write-STStatus 'WorkspaceId not found in vault' -Level WARN -Log
    }
}
if (-not $WorkspaceKey) {
    $getParams = @{ Name = 'WorkspaceKey'; AsPlainText = $true; ErrorAction = 'SilentlyContinue' }
    if ($PSBoundParameters.ContainsKey('Vault')) { $getParams.Vault = $Vault }
    $val = Get-Secret @getParams
    if ($val) {
        $WorkspaceKey = $val
        Write-STStatus 'Loaded WorkspaceKey from vault' -Level SUB -Log
    } else {
        Write-STStatus 'WorkspaceKey not found in vault' -Level WARN -Log
    }
}

if (-not $WorkspaceId -or -not $WorkspaceKey) {
    Write-STStatus -Message 'WorkspaceId and WorkspaceKey are required.' -Level ERROR
    return
}

# Determine telemetry log path
if ($env:ST_TELEMETRY_PATH) {
    $logPath = $env:ST_TELEMETRY_PATH
} else {
    $profile = if ($env:USERPROFILE) { $env:USERPROFILE } else { $env:HOME }
    $logPath = Join-Path $profile 'SupportToolsTelemetry/telemetry.jsonl'
}

if (-not (Test-Path $logPath)) {
    Write-STStatus "Telemetry log not found: $logPath" -Level ERROR
    return
}

Write-STStatus "Loading telemetry from $logPath" -Level INFO -Log
$events = Get-Content -Path $logPath | ForEach-Object { $_ | ConvertFrom-Json }

if (-not $events) {
    Write-STStatus -Message 'No telemetry events to send.' -Level WARN -Log
    return
}

$logType = 'SupportToolsTelemetry'
$apiVer  = '2016-04-01'
$date    = (Get-Date).ToUniversalTime().ToString('r')
$body    = $events | ConvertTo-Json -Depth 5
$bytes   = [Text.Encoding]::UTF8.GetBytes($body)
$stringToSign = "POST`n$($bytes.Length)`napplication/json`nx-ms-date:$date`n/api/logs"
$keyBytes = [Convert]::FromBase64String($WorkspaceKey)
$hmac = [System.Security.Cryptography.HMACSHA256]::new($keyBytes)
$signature = [Convert]::ToBase64String($hmac.ComputeHash([Text.Encoding]::UTF8.GetBytes($stringToSign)))
$auth = "SharedKey $WorkspaceId:$signature"
$uri  = "https://$WorkspaceId.ods.opinsights.azure.com/api/logs?api-version=$apiVer"

$headers = @{ 
    'Authorization' = $auth
    'Log-Type' = $logType
    'x-ms-date' = $date
    'time-generated-field' = 'Timestamp'
}

Write-STStatus "Sending $($events.Count) events to Log Analytics" -Level INFO -Log
Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body $body -ContentType 'application/json' | Out-Null
Write-STStatus -Message 'Telemetry sent successfully.' -Level SUCCESS -Log

Write-STDivider -Title 'TELEMETRY SUMMARY'
$summary = Get-STTelemetryMetrics -LogPath $logPath
foreach ($m in $summary) {
    Write-STBlock -Data @{
        Script = $m.Script
        Executions = $m.Executions
        Successes = $m.Successes
        Failures = $m.Failures
        AverageSeconds = $m.AverageSeconds
        LastRun = $m.LastRun
    }
}
Write-STClosing

