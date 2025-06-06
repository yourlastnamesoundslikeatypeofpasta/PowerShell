$PublicDir = Join-Path $PSScriptRoot 'Public'
$PrivateDir = Join-Path $PSScriptRoot 'Private'
$loggingModule = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath 'Logging/Logging.psd1'
$telemetryModule = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath 'Telemetry/Telemetry.psd1'
Import-Module $loggingModule -ErrorAction SilentlyContinue
Import-Module $telemetryModule -ErrorAction SilentlyContinue

Get-ChildItem -Path "$PrivateDir/*.ps1" -ErrorAction SilentlyContinue | ForEach-Object { . $_.FullName }
Get-ChildItem -Path "$PublicDir/*.ps1" -ErrorAction SilentlyContinue | ForEach-Object { . $_.FullName }

Export-ModuleMember -Function 'Add-UserToGroup','Clear-ArchiveFolder','Clear-TempFile','Convert-ExcelToCsv','Get-CommonSystemInfo','Get-FailedLogin','Get-NetworkShare','Get-UniquePermission','Install-Font','Invoke-PostInstall','Export-ProductKey','Invoke-DeploymentTemplate','Search-ReadMe','Set-ComputerIPAddress','Set-NetAdapterMetering','Set-TimeZoneEasternStandardTime','Start-Countdown','Update-Sysmon','Set-SharedMailboxAutoReply','Invoke-ExchangeCalendarManager','Invoke-CompanyPlaceManagement','Submit-SystemInfoTicket','Generate-SPUsageReport'

function Show-SupportToolsBanner {
    Write-STStatus '════════════════════════════════════════════' -Level INFO
    Write-STStatus 'SUPPORTTOOLS MODULE ACTIVATED' -Level SUCCESS
    Write-STStatus '════════════════════════════════════════════' -Level INFO
    Write-STStatus "Run 'Get-Command -Module SupportTools' to view available tools." -Level SUB
    Write-STLog 'SupportTools module loaded'
}

Show-SupportToolsBanner
