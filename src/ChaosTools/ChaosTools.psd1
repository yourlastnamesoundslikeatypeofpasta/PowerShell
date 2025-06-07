@{
    RootModule = 'ChaosTools.psm1'
    ModuleVersion = '1.0.0'
    GUID = 'b6b7e080-4ad4-4d58-8b8c-000000000013'
    Author = 'Contoso'
    Description = 'Chaos testing helpers.'
    RequiredModules = @('Logging')
    PrivateData = @{ PSData = @{ Tags = @('PowerShell','Chaos','Internal') } }
    FunctionsToExport = @('Invoke-ChaosTest')
}
