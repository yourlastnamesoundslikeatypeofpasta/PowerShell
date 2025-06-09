@{
    RootModule = 'IncidentResponseTools.psm1'
    ModuleVersion = '1.0.0'
    GUID = 'b6b7e080-4ad4-4d58-8b8c-000000000101'
    Author = 'Contoso'
    Description = 'Incident response helper commands.'
    RequiredModules = @('Logging','SharePointTools','ServiceDeskTools','Telemetry','SupportTools')
    PrivateData = @{ PSData = @{ Tags = @('PowerShell','IncidentResponse','Internal') } }
    FunctionsToExport = @(
        'Get-CommonSystemInfo',
        'Get-FailedLogin',
        'Get-NetworkShare',
        'Invoke-IncidentResponse',
        'Invoke-RemoteAudit',
        'Invoke-FullSystemAudit',
        'New-SystemInfoTicket',
        'Update-Sysmon',
        'Search-Indicators'
    )
}
