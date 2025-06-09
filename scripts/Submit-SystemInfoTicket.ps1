<#+
.SYNOPSIS
    Collect system info, upload the report to SharePoint, and open a Service Desk ticket.
.DESCRIPTION
    Uses the SupportTools, SharePointTools and ServiceDeskTools modules to gather
    system information, upload the JSON report to a configured SharePoint site,
    then create a new ticket referencing the uploaded file.
.PARAMETER SiteName
    Friendly name of the SharePoint site defined via Configure-SharePointTools.
.PARAMETER RequesterEmail
    Email address of the ticket requester.
.PARAMETER Subject
    Subject for the Service Desk ticket. Defaults to "System info from <computername>".
.PARAMETER Description
    Ticket description. Defaults to a short message referencing the report.
.PARAMETER LibraryName
    Document library to upload the report into. Defaults to "Shared Documents".
.PARAMETER FolderPath
    Optional folder path within the library.
.PARAMETER TranscriptPath
    Path for the transcript log file.
.PARAMETER SmtpServer
    Optional SMTP server to deliver the summary email.
#>
param(
    [Parameter(Mandatory)]
    [string]$SiteName,
    [Parameter(Mandatory)]
    [string]$RequesterEmail,
    [string]$Subject = "System info from $env:COMPUTERNAME",
    [string]$Description = 'System information collected automatically.',
    [string]$LibraryName = 'Shared Documents',
    [string]$FolderPath = '',
    [string]$TranscriptPath,
    [string]$SmtpServer
)

Import-Module (Join-Path $PSScriptRoot '..' 'src/Logging/Logging.psd1') -Force -ErrorAction SilentlyContinue
Import-Module (Join-Path $PSScriptRoot '..' 'src/SupportTools/SupportTools.psd1') -Force -ErrorAction SilentlyContinue
Import-Module (Join-Path $PSScriptRoot '..' 'src/SharePointTools/SharePointTools.psd1') -Force -ErrorAction SilentlyContinue
Import-Module (Join-Path $PSScriptRoot '..' 'src/ServiceDeskTools/ServiceDeskTools.psd1') -Force -ErrorAction SilentlyContinue

if ($TranscriptPath) { Start-Transcript -Path $TranscriptPath -Append | Out-Null }

try {
    Write-STStatus -Message 'Gathering system information...' -Level INFO -Log
    $info = Get-CommonSystemInfo
    $tempFile = Join-Path $env:TEMP "systeminfo_$((Get-Date).ToString('yyyyMMdd_HHmmss')).json"
    $info | ConvertTo-Json -Depth 10 | Out-File -FilePath $tempFile -Encoding utf8
    Write-STStatus "Report saved to $tempFile" -Level SUCCESS -Log

    $settings = Get-SPToolsSettings
    $siteUrl = Get-SPToolsSiteUrl -SiteName $SiteName
    Connect-PnPOnline -Url $siteUrl -ClientId $settings.ClientId -Tenant $settings.TenantId -CertificatePath $settings.CertPath

    Write-STStatus -Message 'Uploading report to SharePoint...' -Level INFO -Log
    $targetFolder = if ($FolderPath) { "$LibraryName/$FolderPath" } else { $LibraryName }
    $upload = Add-PnPFile -Path $tempFile -Folder $targetFolder -ErrorAction Stop
    $fileUrl = "$siteUrl$($upload.ServerRelativeUrl)"
    Write-STStatus "Uploaded report to $fileUrl" -Level SUCCESS -Log

    Write-STStatus -Message 'Creating Service Desk ticket...' -Level INFO -Log
    $ticketBody = "$Description`n`nReport: $fileUrl"
    New-SDTicket -Subject $Subject -Description $ticketBody -RequesterEmail $RequesterEmail | Out-Null
    Write-STStatus -Message 'Service Desk ticket created.' -Level SUCCESS -Log

    if ($SmtpServer) {
        Write-STStatus -Message 'Sending summary email...' -Level INFO -Log
        $mailSubject = "System info ticket created on $env:COMPUTERNAME"
        $mailBody = "A Service Desk ticket has been opened with subject '$Subject'.`nReport: $fileUrl"
        Send-MailMessage -To $RequesterEmail -From $RequesterEmail -Subject $mailSubject -Body $mailBody -SmtpServer $SmtpServer
        Write-STStatus -Message 'Summary email sent.' -Level SUCCESS -Log
    }
}
finally {
    if ($TranscriptPath) { Stop-Transcript | Out-Null }
}
