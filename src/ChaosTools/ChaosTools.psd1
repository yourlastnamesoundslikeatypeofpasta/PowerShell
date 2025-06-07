@{
    RootModule = 'ChaosTools.psm1'
    ModuleVersion = '1.0.0'
    GUID = 'b6b7e080-4ad4-4d58-8b8c-000000000013'
    Author = 'Contoso'
    Description = 'Tools for chaos engineering and fault injection.'
    RequiredModules = @('Logging','Telemetry')
    PrivateData = @{ PSData = @{ Tags = @('PowerShell','Chaos','Testing','Internal') } }
    FunctionsToExport = @('Invoke-ChaosTest')
}
