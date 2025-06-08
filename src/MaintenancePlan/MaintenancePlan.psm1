$PublicDir = Join-Path $PSScriptRoot 'Public'
$coreModule = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath 'STCore/STCore.psd1'
$loggingModule = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath 'Logging/Logging.psd1'
Import-Module $coreModule -ErrorAction SilentlyContinue
Import-Module $loggingModule -ErrorAction SilentlyContinue
Get-ChildItem -Path "$PublicDir" -Filter *.ps1 -ErrorAction SilentlyContinue | ForEach-Object { . $_.FullName }

Export-ModuleMember -Function (Get-ChildItem "$PublicDir/*.ps1" -ErrorAction SilentlyContinue).BaseName

function Show-MaintenancePlanBanner {
    [CmdletBinding()]
    param()
    $manifestPath = Join-Path $PSScriptRoot 'MaintenancePlan.psd1'
    [pscustomobject]@{
        Module  = 'MaintenancePlan'
        Version = (Import-PowerShellDataFile $manifestPath).ModuleVersion
    }
}
