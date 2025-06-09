<#+
.SYNOPSIS
    Generate library usage reports and create Service Desk tickets when thresholds are exceeded.
.DESCRIPTION
    Runs Get-SPToolsAllLibraryReports from the SharePointTools module and exports the results to CSV.
    Libraries with an ItemCount greater than the specified threshold trigger a Service Desk ticket.
.PARAMETER ItemThreshold
    Number of items that must be exceeded before a ticket is created.
.PARAMETER RequesterEmail
    Email address for the ticket requester.
.PARAMETER CsvPath
    Path to save the CSV report. Defaults to LibraryReport_<timestamp>.csv in the current directory.
.PARAMETER TranscriptPath
    Optional transcript log path.
#>
param(
    [int]$ItemThreshold = 5000,
    [string]$RequesterEmail,
    [string]$CsvPath = $(Join-Path (Get-Location) "LibraryReport_$((Get-Date).ToString('yyyyMMdd_HHmmss')).csv"),
    [string]$TranscriptPath
)

Import-Module (Join-Path $PSScriptRoot '..' 'src/Logging/Logging.psd1') -ErrorAction SilentlyContinue
Import-Module (Join-Path $PSScriptRoot '..' 'src/SharePointTools/SharePointTools.psd1') -ErrorAction SilentlyContinue
Import-Module (Join-Path $PSScriptRoot '..' 'src/ServiceDeskTools/ServiceDeskTools.psd1') -ErrorAction SilentlyContinue

if ($TranscriptPath) { Start-Transcript -Path $TranscriptPath -Append | Out-Null }

try {
    Write-STStatus -Message 'Generating library usage report...' -Level INFO -Log
    $report = Get-SPToolsAllLibraryReports
    $report | Export-Csv -Path $CsvPath -NoTypeInformation
    Write-STStatus "Report saved to $CsvPath" -Level SUCCESS -Log

    if ($RequesterEmail) {
        $over = $report | Where-Object { $_.ItemCount -gt $ItemThreshold }
        foreach ($siteGroup in $over | Group-Object SiteName) {
            $subject = "SharePoint library usage over $ItemThreshold items - $($siteGroup.Name)"
            $desc = ($siteGroup.Group | Format-Table LibraryName, ItemCount -AutoSize | Out-String)
            Write-STStatus "Creating ticket for site $($siteGroup.Name)..." -Level INFO -Log
            New-SDTicket -Subject $subject -Description $desc -RequesterEmail $RequesterEmail | Out-Null
        }
    }
}
finally {
    if ($TranscriptPath) { Stop-Transcript | Out-Null }
}
