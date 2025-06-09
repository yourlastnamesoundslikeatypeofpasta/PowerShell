$PublicDir = Join-Path $PSScriptRoot 'Public'
$PrivateDir = Join-Path $PSScriptRoot 'Private'
$loggingModule = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath 'Logging/Logging.psd1'
$telemetryModule = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath 'Telemetry/Telemetry.psd1'
Import-Module $loggingModule -ErrorAction SilentlyContinue
Import-Module $telemetryModule -ErrorAction SilentlyContinue

Get-ChildItem -Path "$PrivateDir/*.ps1" -ErrorAction SilentlyContinue | ForEach-Object { . $_.FullName }
Get-ChildItem -Path "$PublicDir/*.ps1" -ErrorAction SilentlyContinue | ForEach-Object { . $_.FullName }

Export-ModuleMember -Function 'Get-GraphUserDetails','Get-GraphGroupDetails','Get-UserInfoHybrid','Disable-GraphUser','Get-GraphSignInLogs','Get-GraphRiskySignIns','Watch-GraphSignIns'

function Show-EntraIDToolsBanner {
    <#
    .SYNOPSIS
        Returns EntraIDTools module metadata for banner display.
    #>
    [CmdletBinding()]
    param()
    $manifestPath = Join-Path $PSScriptRoot 'EntraIDTools.psd1'
    [pscustomobject]@{
        Module  = 'EntraIDTools'
        Version = (Import-PowerShellDataFile $manifestPath).ModuleVersion
    }
}
