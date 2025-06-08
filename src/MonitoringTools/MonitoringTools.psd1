@{
    RootModule = 'MonitoringTools.psm1'
    ModuleVersion = '1.0.0'
    GUID = 'b6b7e080-4ad4-4d58-8b8c-000000000050'
    Author = 'Contoso'
    Description = 'System monitoring utilities.'
    RequiredModules = @('Logging')
    PrivateData = @{ PSData = @{ Tags = @('PowerShell','Monitoring','Internal') } }
    FunctionsToExport = @('Get-DiskSpace','Get-CPUUsage','Get-EventLogSummary','Get-SystemHealth')
}
