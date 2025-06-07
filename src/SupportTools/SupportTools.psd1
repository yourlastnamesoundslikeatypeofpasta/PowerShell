@{
    RootModule = 'SupportTools.psm1'
    ModuleVersion = '1.4.0'
    GUID = 'b6b7e080-4ad4-4d58-8b8c-000000000001'
    Author = 'Contoso'
    Description = 'Collection of helper functions wrapping existing scripts.'
    RequiredModules = @('Logging','SharePointTools','ServiceDeskTools','Telemetry')
    PrivateData = @{ 
        PSData = @{ 
            Tags = @('PowerShell','SupportTools','SharePoint','ServiceDesk','Internal')
            ProjectUri = 'https://contoso.com/supporttools'
            LicenseUri = 'https://contoso.com/license'
        }
    }

    NestedModules = @(
        '../Logging/Logging.psd1',
        '../Telemetry/Telemetry.psd1'
    )

    FunctionsToExport = @(
        'Add-UserToGroup',
        'Clear-ArchiveFolder',
        'Clear-TempFile',
        'Convert-ExcelToCsv',
        'Export-ProductKey',
        'New-SPUsageReport',
        'Get-CommonSystemInfo',
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
}
