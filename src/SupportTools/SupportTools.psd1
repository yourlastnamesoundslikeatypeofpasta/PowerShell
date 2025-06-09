@{
    RootModule = 'SupportTools.psm1'
    ModuleVersion = '1.5.0'
    GUID = 'b6b7e080-4ad4-4d58-8b8c-000000000001'
    Author = 'Contoso'
    Description = 'Collection of helper functions wrapping existing scripts.'
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
    # The Logging and Telemetry modules provide common interfaces for
    # injecting custom implementations when executing SupportTools commands.

    FunctionsToExport = @(
        'Clear-ArchiveFolder',
        'Clear-TempFile',
        'Convert-ExcelToCsv',
        'Export-ProductKey',
        'New-SPUsageReport',
        'Get-UniquePermission',
        'Invoke-JobBundle',
        'Invoke-PerformanceAudit',
        'Restore-ArchiveFolder',
        'Search-ReadMe',
        'Start-Countdown',
        'Export-ITReport',
        'New-STDashboard',
        'Sync-SupportTools',
        'Invoke-NewHireUserAutomation'
    )

    AliasesToExport = @(
        'NewHire-Automation'
    )
}
