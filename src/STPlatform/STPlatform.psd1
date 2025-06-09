@{
    RootModule = 'STPlatform.psm1'
    ModuleVersion = '1.0.0'
    GUID = 'b6b7e080-4ad4-4d58-8b8c-000000000012'
    Author = 'Contoso'
    Description = 'Platform initialization utilities.'
    RequiredModules = @('Logging','Telemetry')
    FunctionsToExport = @('Connect-STPlatform','Connect-EntraID')
}
