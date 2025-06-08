@{
    RootModule = 'MaintenancePlan.psm1'
    ModuleVersion = '1.0.0'
    GUID = 'b6b7e080-4ad4-4d58-8b8c-000000000050'
    Author = 'Contoso'
    Description = 'Manage scheduled maintenance plans.'
    FunctionsToExport = @('New-MaintenancePlan','Export-MaintenancePlan','Import-MaintenancePlan','Invoke-MaintenancePlan')
}
