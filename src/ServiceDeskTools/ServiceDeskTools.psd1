@{
    RootModule = 'ServiceDeskTools.psm1'
    ModuleVersion = '1.3.0'
    GUID = 'b6b7e080-4ad4-4d58-8b8c-000000000003'
    Author = 'Contoso'
    Description = 'Commands for interacting with the Service Desk ticketing system.'
    RequiredModules = @('Logging')
    PrivateData = @{ PSData = @{ Tags = @('PowerShell','ServiceDesk','Internal') } }
    FunctionsToExport = '*'
}
