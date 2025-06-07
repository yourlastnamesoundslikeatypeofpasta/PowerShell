$PublicDir = Join-Path $PSScriptRoot 'Public'
$PrivateDir = Join-Path $PSScriptRoot 'Private'
$loggingModule = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath 'Logging/Logging.psd1'
Import-Module $loggingModule -ErrorAction SilentlyContinue

Get-ChildItem -Path "$PrivateDir/*.ps1" -ErrorAction SilentlyContinue |
    ForEach-Object { . $_.FullName }
Get-ChildItem -Path "$PublicDir" -Filter *.ps1 -ErrorAction SilentlyContinue |
    ForEach-Object { . $_.FullName }

Export-ModuleMember -Function (
    Get-ChildItem "$PublicDir/*.ps1" -ErrorAction SilentlyContinue
).BaseName

function Show-ServiceDeskToolsBanner {
    Write-STDivider 'SERVICEDESKTOOLS MODULE LOADED' -Style heavy
    Write-STStatus "Run 'Get-Command -Module ServiceDeskTools' to view available tools." -Level SUB
    Write-STLog -Message 'ServiceDeskTools module loaded'
}

Show-ServiceDeskToolsBanner
