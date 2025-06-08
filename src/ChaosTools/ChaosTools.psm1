$coreModule = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath 'STCore/STCore.psd1'
$loggingModule = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath 'Logging/Logging.psd1'
Import-Module $coreModule -ErrorAction SilentlyContinue
Import-Module $loggingModule -ErrorAction SilentlyContinue

$PublicDir = Join-Path $PSScriptRoot 'Public'
Get-ChildItem -Path "$PublicDir/*.ps1" -ErrorAction SilentlyContinue | ForEach-Object { . $_.FullName }

Export-ModuleMember -Function 'Invoke-ChaosTest'

function Show-ChaosToolsBanner {
    <#
    .SYNOPSIS
        Returns ChaosTools module metadata for banner display.
    #>
    [CmdletBinding()]
    param()
    $manifestPath = Join-Path $PSScriptRoot 'ChaosTools.psd1'
    [pscustomobject]@{
        Module  = 'ChaosTools'
        Version = (Import-PowerShellDataFile $manifestPath).ModuleVersion
    }
}
