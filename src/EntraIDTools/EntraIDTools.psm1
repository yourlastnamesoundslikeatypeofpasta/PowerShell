$PublicDir = Join-Path $PSScriptRoot 'Public'
$PrivateDir = Join-Path $PSScriptRoot 'Private'
$loggingModule = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath 'Logging/Logging.psd1'
$telemetryModule = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath 'Telemetry/Telemetry.psd1'
Import-Module $loggingModule -ErrorAction SilentlyContinue
Import-Module $telemetryModule -ErrorAction SilentlyContinue

Get-ChildItem -Path "$PrivateDir/*.ps1" -ErrorAction SilentlyContinue | ForEach-Object { . $_.FullName }
Get-ChildItem -Path "$PublicDir/*.ps1" -ErrorAction SilentlyContinue | ForEach-Object { . $_.FullName }

Export-ModuleMember -Function 'Get-GraphUserDetails','Get-GraphGroupDetails','Get-UserInfoHybrid'

function Show-EntraIDToolsBanner {
    <#
    .SYNOPSIS
        Displays the EntraIDTools module banner.
    #>
    [CmdletBinding()]
    param()
    Write-STDivider 'ENTRAIDTOOLS MODULE LOADED' -Style heavy
    Write-STStatus "Run 'Get-Command -Module EntraIDTools' to view available tools." -Level SUB
    Write-STLog -Message 'EntraIDTools module loaded'
}

Show-EntraIDToolsBanner
