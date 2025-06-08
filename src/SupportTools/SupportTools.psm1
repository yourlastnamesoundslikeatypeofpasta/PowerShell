$PublicDir = Join-Path $PSScriptRoot 'Public'
$PrivateDir = Join-Path $PSScriptRoot 'Private'
$coreModule = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath 'STCore/STCore.psd1'
$loggingModule = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath 'Logging/Logging.psd1'
$telemetryModule = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath 'Telemetry/Telemetry.psd1'
$monitoringModule = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath 'MonitoringTools/MonitoringTools.psd1'
Import-Module $coreModule -ErrorAction SilentlyContinue
Import-Module $loggingModule -ErrorAction SilentlyContinue
Import-Module $telemetryModule -ErrorAction SilentlyContinue
Import-Module $monitoringModule -ErrorAction SilentlyContinue

# Determine the version of the SupportTools module for logging purposes
$manifestPath = Join-Path $PSScriptRoot 'SupportTools.psd1'
$STModuleVersion = try {
    (Import-PowerShellDataFile $manifestPath).ModuleVersion
} catch {
    'unknown'
}

Get-ChildItem -Path "$PrivateDir/*.ps1" -ErrorAction SilentlyContinue |
    ForEach-Object { . $_.FullName }
Get-ChildItem -Path "$PublicDir" -Filter *.ps1 -ErrorAction SilentlyContinue |
    ForEach-Object { . $_.FullName }


Export-ModuleMember -Function @(
    'Add-UserToGroup',
    'Clear-ArchiveFolder',
    'Clear-TempFile',
    'Convert-ExcelToCsv',
    'Export-ProductKey',
    'New-SPUsageReport',
    'Get-FailedLogin',
    'Get-NetworkShare',
    'Get-UniquePermission',
    'Install-Font',
    'Install-MaintenanceTasks',
    'Invoke-CompanyPlaceManagement',
    'Invoke-DeploymentTemplate',
    'Invoke-ExchangeCalendarManager',
    'Invoke-GroupMembershipCleanup',
    'Invoke-JobBundle',
    'Invoke-PostInstall',
    'Invoke-PerformanceAudit',
    'Invoke-RemoteAudit',
    'Invoke-FullSystemAudit',
    'Restore-ArchiveFolder',
    'Search-ReadMe',
    'Set-ComputerIPAddress',
    'Set-NetAdapterMetering',
    'Set-SharedMailboxAutoReply',
    'Set-TimeZoneEasternStandardTime',
    'Start-Countdown',
    'Invoke-IncidentResponse',
    'Submit-SystemInfoTicket',
    'Sync-SupportTools',
    'Update-Sysmon'
)


function Show-SupportToolsBanner {
    Write-STDivider 'SUPPORTTOOLS MODULE LOADED' -Style heavy
    Write-STStatus "Run 'Get-Command -Module SupportTools' to view available tools." -Level SUB
    Write-STLog -Message 'SupportTools module loaded'
}

Show-SupportToolsBanner
