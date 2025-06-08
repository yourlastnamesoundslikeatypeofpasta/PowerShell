@{
    RootModule = 'MonitoringTools.psm1'
    ModuleVersion = '1.0.0'
    GUID = 'b6b7e080-4ad4-4d58-8b8c-000000000020'
    Author = 'Contoso'
    Description = 'System monitoring commands.'
    RequiredModules = @('Logging')
    FunctionsToExport = @(
        'Get-DiskSpace',
        'Get-CPUUsage',
        'Get-SystemEventLogs',
        'Get-SystemHealth',
        'Get-CommonSystemInfo'
    )
    PrivateData = @{ PSData = @{ Tags = @('PowerShell','Monitoring','Internal') } }
}
