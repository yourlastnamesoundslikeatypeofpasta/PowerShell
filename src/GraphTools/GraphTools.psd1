@{
    RootModule = 'GraphTools.psm1'
    ModuleVersion = '1.0.0'
    GUID = 'b6b7e080-4ad4-4d58-8b8c-000000000012'
    Author = 'Contoso'
    Description = 'Microsoft Graph helper functions.'
    RequiredModules = @('Logging','Telemetry')
    PrivateData = @{
        PSData = @{
            Tags = @('PowerShell','Graph','Internal')
            ReleaseNotes = 'Initial stable release of GraphTools.'
        }
    }
    FunctionsToExport = @('Get-GraphUserDetails','Get-GraphGroupDetails')
}
