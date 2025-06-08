using module "./TicketObject.psm1"
$PublicDir = Join-Path $PSScriptRoot 'Public'
$PrivateDir = Join-Path $PSScriptRoot 'Private'
$coreModule = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath 'STCore/STCore.psd1'
$loggingModule = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath 'Logging/Logging.psd1'
Import-Module $coreModule -ErrorAction SilentlyContinue
Import-Module $loggingModule -ErrorAction SilentlyContinue

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
        Displays the ServiceDeskTools module banner.
    #>
    [CmdletBinding()]
    param()
    Write-STDivider 'SERVICEDESKTOOLS MODULE LOADED' -Style heavy
    Write-STStatus "Run 'Get-Command -Module ServiceDeskTools' to view available tools." -Level SUB
    Write-STLog -Message 'ServiceDeskTools module loaded'
}

Show-ServiceDeskToolsBanner
