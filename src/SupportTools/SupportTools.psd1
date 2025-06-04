@{
    RootModule = 'SupportTools.psm1'
    ModuleVersion = '1.2.0'
    GUID = 'b6b7e080-4ad4-4d58-8b8c-000000000001'
    Author = 'Contoso'
    Description = 'Collection of helper functions wrapping existing scripts.'
    FunctionsToExport = @(
        'AddUsersToGroup',
        'CleanupArchive',
        'Convert-ExcelToCsv',
        'Get-CommonSystemInfo',
        'Get-FailedLogins',
        'Get-NetworkShares',
        'Get-UniquePermissions',
        'Install-Fonts',
        'PostInstallScript',
        'ProductKey',
        'Invoke-DeploymentTemplate',
        'Search-ReadMe',
        'Set-ComputerIPAddress',
        'Set-NetAdapterMetering',
        'Set-TimeZoneEasternStandardTime',
        'SimpleCountdown',
        'Update-Sysmon',
        'Set-SharedMailboxAutoReply',
        'Invoke-ExchangeCalendarManager'
    )
}
