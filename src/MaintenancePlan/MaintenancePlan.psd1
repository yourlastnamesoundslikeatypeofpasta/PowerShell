@{
    RootModule = 'MaintenancePlan.psm1'
    ModuleVersion = '1.0.0'
    GUID = 'b6b7e080-4ad4-4d58-8b8c-000000000015'
    Author = 'Contoso'
    Description = 'Create and manage maintenance plans.'
    RequiredModules = @('Logging')
    PrivateData = @{ PSData = @{ Tags = @('PowerShell','Maintenance','Internal') } }
    FunctionsToExport = @('New-MaintenancePlan','Export-MaintenancePlan','Import-MaintenancePlan','Invoke-MaintenancePlan','Register-MaintenancePlan','Show-MaintenancePlan')
}
