@{
    RootModule = 'ConfigManagementTools.psm1'
    ModuleVersion = '1.0.0'
    GUID = 'b6b7e080-4ad4-4d58-8b8c-000000000102'
    Author = 'Contoso'
    Description = 'Configuration management helper commands.'
    RequiredModules = @('Logging','SharePointTools','ServiceDeskTools','Telemetry')
    PrivateData = @{ PSData = @{ Tags = @('PowerShell','ConfigManagement','Internal') } }
    FunctionsToExport = @(
        'Add-UserToGroup',
        'Invoke-GroupMembershipCleanup',
        'Install-Font',
        'Install-MaintenanceTasks',
        'Invoke-CompanyPlaceManagement',
        'Invoke-DeploymentTemplate',
        'Invoke-ExchangeCalendarManager',
        'Invoke-PostInstall',
        'Set-ComputerIPAddress',
        'Set-NetAdapterMetering',
        'Set-SharedMailboxAutoReply',
        'Set-TimeZoneEasternStandardTime',
        'Test-Drift'
    )
}
