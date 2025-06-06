@{
    RootModule = 'SupportTools.psm1'
    ModuleVersion = '1.3.0'
    GUID = 'b6b7e080-4ad4-4d58-8b8c-000000000001'
    Author = 'Contoso'
    Description = 'Collection of helper functions wrapping existing scripts.'
    FunctionsToExport = @(
        'Add-UserToGroup',
        'Clear-ArchiveFolder',
        'Clear-TempFile',
        'Convert-ExcelToCsv',
        'Get-CommonSystemInfo',
        'Get-FailedLogin',
        'Get-NetworkShare',
        'Get-UniquePermission',
        'Install-Font',
        'Invoke-PostInstall',
        'Export-ProductKey',
        'Invoke-DeploymentTemplate',
        'Search-ReadMe',
        'Set-ComputerIPAddress',
        'Set-NetAdapterMetering',
        'Set-TimeZoneEasternStandardTime',
        'Start-Countdown',
        'Update-Sysmon',
        'Set-SharedMailboxAutoReply',
        'Invoke-ExchangeCalendarManager','Invoke-CompanyPlaceManagement','Submit-SystemInfoTicket','Generate-SPUsageReport','Install-MaintenanceTasks','Invoke-GroupMembershipCleanup'
    )
}
