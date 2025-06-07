$coreModule = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath 'STCore/STCore.psd1'
$loggingModule = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath 'Logging/Logging.psd1'
Import-Module $coreModule -ErrorAction SilentlyContinue
Import-Module $loggingModule -ErrorAction SilentlyContinue

$PublicDir = Join-Path $PSScriptRoot 'Public'
Get-ChildItem -Path "$PublicDir/*.ps1" -ErrorAction SilentlyContinue | ForEach-Object { . $_.FullName }

Export-ModuleMember -Function 'Invoke-ChaosTest'

function Show-ChaosToolsBanner {
    Write-STDivider 'CHAOSTOOLS MODULE LOADED' -Style heavy
    Write-STStatus "Run 'Get-Command -Module ChaosTools' to view available tools." -Level SUB
    Write-STLog -Message 'ChaosTools module loaded'
}

Show-ChaosToolsBanner
