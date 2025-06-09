<#
.SYNOPSIS
    Emails a summary of SupportTools telemetry metrics.
.DESCRIPTION
    Reads telemetry events from the local log and summarizes them using
    Get-STTelemetryMetrics. The formatted summary is emailed using
    Send-MailMessage.
.PARAMETER To
    Recipient email address for the summary.
.PARAMETER From
    Sender email address.
.PARAMETER SmtpServer
    SMTP server used to send the message.
.PARAMETER LogPath
    Optional path to the telemetry log.
.PARAMETER Subject
    Optional subject line for the email. Defaults to "Telemetry Summary".
.EXAMPLE
    ./Send-TelemetrySummary.ps1 -To admin@contoso.com -From noreply@contoso.com -SmtpServer smtp.contoso.com
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$To,

    [Parameter(Mandatory)]
    [string]$From,

    [Parameter(Mandatory)]
    [string]$SmtpServer,

    [string]$LogPath,

    [string]$Subject = 'Telemetry Summary'
)

Import-Module (Join-Path $PSScriptRoot '..' 'src/Logging/Logging.psd1') -Force -ErrorAction SilentlyContinue
Import-Module (Join-Path $PSScriptRoot '..' 'src/Telemetry/Telemetry.psd1') -Force -ErrorAction SilentlyContinue

Show-STPrompt './scripts/Send-TelemetrySummary.ps1'

if ($env:ST_ENABLE_TELEMETRY -ne '1') {
    Write-STStatus -Message 'ST_ENABLE_TELEMETRY is not set. Telemetry will not be read.' -Level WARN
    return
}

if ($LogPath) {
    $path = $LogPath
} elseif ($env:ST_TELEMETRY_PATH) {
    $path = $env:ST_TELEMETRY_PATH
} else {
    $profile = if ($env:USERPROFILE) { $env:USERPROFILE } else { $env:HOME }
    $path = Join-Path $profile 'SupportToolsTelemetry/telemetry.jsonl'
}

if (-not (Test-Path $path)) {
    Write-STStatus "Telemetry log not found: $path" -Level ERROR
    return
}

Write-STStatus -Message 'Generating telemetry metrics...' -Level INFO -Log
$metrics = Get-STTelemetryMetrics -LogPath $path

if (-not $metrics) {
    Write-STStatus -Message 'No telemetry events found.' -Level WARN
    return
}

$body = $metrics | Format-Table -AutoSize | Out-String

Write-STStatus -Message 'Sending email...' -Level INFO -Log
Send-MailMessage -To $To -From $From -Subject $Subject -Body $body -SmtpServer $SmtpServer

Write-STStatus -Message 'Telemetry summary sent.' -Level SUCCESS -Log
Write-STClosing
