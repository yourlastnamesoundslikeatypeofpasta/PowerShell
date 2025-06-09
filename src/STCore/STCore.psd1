@{
    RootModule = 'STCore.psm1'
    ModuleVersion = '1.0.0'
    GUID = 'b6b7e080-4ad4-4d58-8b8c-000000000000'
    Author = 'Contoso'
    Description = 'Core utility functions.'
    FunctionsToExport = @('Assert-ParameterNotNull','New-STErrorObject','New-STErrorRecord','Write-STDebug','Write-STFailure','Test-IsElevated','Get-STConfig','Invoke-STRequest')
}
