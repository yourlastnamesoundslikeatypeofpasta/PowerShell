@{
    RootModule = 'PerformanceTools.psm1'
    ModuleVersion = '1.0.0'
    GUID = 'b6b7e080-4ad4-4d58-8b8c-000000000012'
    Author = 'Contoso'
    Description = 'Commands for measuring script performance.'
    RequiredModules = @('Logging')
    PrivateData = @{ PSData = @{ Tags = @('PowerShell','Performance','Internal') } }
    FunctionsToExport = @('Measure-STCommand')
}
