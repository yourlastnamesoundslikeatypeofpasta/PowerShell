<#+
.SYNOPSIS
    Runs a SharePoint permission audit, logs the results and creates a Service Desk ticket.
.DESCRIPTION
    This orchestration script demonstrates how the Logging, Telemetry, SharePointTools and
    ServiceDeskTools modules can be combined. The script generates a permissions report
    using Get-SPPermissionsReport, logs progress messages, records usage telemetry and
    opens a Service Desk ticket summarizing the audit.
.PARAMETER SiteUrl
    URL of the SharePoint site to audit.
.PARAMETER RequesterEmail
    Email address of the requester for the generated ticket.
.PARAMETER FolderUrl
    Optional folder URL for a more targeted audit.
.PARAMETER TranscriptPath
    Path to write a transcript log file.
.PARAMETER ChaosMode
    Enable API Chaos Mode when creating the ticket.
.EXAMPLE
    ./Invoke-DailyAuditWorkflow.ps1 -SiteUrl https://contoso.sharepoint.com/sites/hr \
        -RequesterEmail 'admin@contoso.com'
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$SiteUrl,

    [Parameter(Mandatory)]
    [string]$RequesterEmail,

    [string]$FolderUrl,

    [string]$TranscriptPath,

    [switch]$ChaosMode
)

$scriptName = $MyInvocation.MyCommand.Name
$ErrorActionPreference = 'Stop'

# Import required modules from the repository
Import-Module (Join-Path $PSScriptRoot '..' 'src/Logging/Logging.psd1') -Force -ErrorAction Stop
Import-Module (Join-Path $PSScriptRoot '..' 'src/Telemetry/Telemetry.psd1') -Force -ErrorAction Stop
Import-Module (Join-Path $PSScriptRoot '..' 'src/SharePointTools/SharePointTools.psd1') -Force -ErrorAction Stop
Import-Module (Join-Path $PSScriptRoot '..' 'src/ServiceDeskTools/ServiceDeskTools.psd1') -Force -ErrorAction Stop

if ($TranscriptPath) { Start-Transcript -Path $TranscriptPath -Append | Out-Null }

$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
$result = 'Success'
$ticket = $null
$reportPath = $null
try {
    Write-STStatus "Running permission audit on $SiteUrl" -Level INFO -Log
    $report = Get-SPPermissionsReport -SiteUrl $SiteUrl -FolderUrl $FolderUrl
    Write-STStatus "Found $($report.Count) permission assignments" -Level SUCCESS -Log

    $reportDir = Join-Path $env:TEMP 'DailyAudit'
    if (-not (Test-Path $reportDir)) { New-Item -Path $reportDir -ItemType Directory | Out-Null }
    $reportPath = Join-Path $reportDir "permissions_$((Get-Date).ToString('yyyyMMdd_HHmmss')).csv"
    $report | Export-Csv -NoTypeInformation -Path $reportPath
    Write-STStatus "Report saved to $reportPath" -Level INFO -Log

    $body = "Daily SharePoint permission audit completed.`n`nSite: $SiteUrl`nEntries: $($report.Count)`nReport: $reportPath"
    $ticket = New-SDTicket -Subject "Daily Audit - $SiteUrl" -Description $body -RequesterEmail $RequesterEmail -ChaosMode:$ChaosMode
    Write-STStatus "Created Service Desk ticket ID $($ticket.id)" -Level SUCCESS -Log

    [pscustomobject]@{
        Report     = $report
        ReportPath = $reportPath
        Ticket     = $ticket
    }
}
catch {
    Write-STStatus "Audit failed: $_" -Level ERROR -Log
    $result = 'Failure'
    throw
}
finally {
    $stopwatch.Stop()
    Write-STTelemetryEvent -ScriptName $scriptName -Result $result -Duration $stopwatch.Elapsed
    if ($TranscriptPath) { Stop-Transcript | Out-Null }
}
