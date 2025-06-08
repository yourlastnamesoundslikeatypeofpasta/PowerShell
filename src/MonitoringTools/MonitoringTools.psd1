@{
    RootModule = 'MonitoringTools.psm1'
    ModuleVersion = '1.0.0'
    GUID = 'b6b7e080-4ad4-4d58-8b8c-000000000110'
    Author = 'Contoso'
    Description = 'Commands for collecting system monitoring data.'
    RequiredModules = @('Logging','Telemetry')
    PrivateData = @{ PSData = @{ Tags = @('PowerShell','Monitoring','Internal') } }
    FunctionsToExport = @('Get-CPUUsage','Get-DiskSpaceInfo','Get-EventLogSummary','Get-SystemHealth','Start-HealthMonitor')
}
