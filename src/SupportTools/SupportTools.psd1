@{
    RootModule = 'SupportTools.psm1'
    ModuleVersion = '1.3.0'
    GUID = 'b6b7e080-4ad4-4d58-8b8c-000000000001'
    Author = 'Contoso'
    Description = 'Collection of helper functions wrapping existing scripts.'
    FunctionsToExport = @(
        'Add-UsersToGroup',
        'Clear-ArchiveFolder',
        'Convert-ExcelToCsv',
        'Get-CommonSystemInfo',
        'Get-FailedLogins',
        'Get-NetworkShares',
        'Get-UniquePermissions',
        'Install-Fonts',
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
        'Invoke-ExchangeCalendarManager','Invoke-CompanyPlaceManagement'
    )
}
