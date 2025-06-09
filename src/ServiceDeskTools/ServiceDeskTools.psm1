using module "./TicketObject.psm1"
$PublicDir = Join-Path $PSScriptRoot 'Public'
$PrivateDir = Join-Path $PSScriptRoot 'Private'
$coreModule = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath 'STCore/STCore.psd1'
$loggingModule = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath 'Logging/Logging.psd1'
$telemetryModule = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath 'Telemetry/Telemetry.psd1'
Import-Module $coreModule -Force -ErrorAction SilentlyContinue
Import-Module $loggingModule -Force -ErrorAction SilentlyContinue
Import-Module $telemetryModule -Force -ErrorAction SilentlyContinue

Get-ChildItem -Path "$PrivateDir/*.ps1" -ErrorAction SilentlyContinue |
    ForEach-Object { . $_.FullName }
Get-ChildItem -Path "$PublicDir" -Filter *.ps1 -ErrorAction SilentlyContinue |
    ForEach-Object { . $_.FullName }

Export-ModuleMember -Function (
    Get-ChildItem "$PublicDir/*.ps1" -ErrorAction SilentlyContinue
).BaseName

function Show-ServiceDeskToolsBanner {
    <#
    .SYNOPSIS
        Returns ServiceDeskTools module metadata for banner display.
    #>
    [CmdletBinding()]
    param()
    $manifestPath = Join-Path $PSScriptRoot 'ServiceDeskTools.psd1'
    [pscustomobject]@{
        Module  = 'ServiceDeskTools'
        Version = (Import-PowerShellDataFile $manifestPath).ModuleVersion
    }
}
