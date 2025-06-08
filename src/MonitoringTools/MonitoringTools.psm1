$PublicDir = Join-Path $PSScriptRoot 'Public'
$PrivateDir = Join-Path $PSScriptRoot 'Private'
$coreModule = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath 'STCore/STCore.psd1'
$loggingModule = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath 'Logging/Logging.psd1'
Import-Module $coreModule -ErrorAction SilentlyContinue
Import-Module $loggingModule -ErrorAction SilentlyContinue

Get-ChildItem -Path "$PrivateDir/*.ps1" -ErrorAction SilentlyContinue | ForEach-Object { . $_.FullName }
Get-ChildItem -Path "$PublicDir/*.ps1" -ErrorAction SilentlyContinue | ForEach-Object { . $_.FullName }

Export-ModuleMember -Function 'Get-DiskSpace','Get-CPUUsage','Get-SystemEventLogs','Get-SystemHealth','Get-CommonSystemInfo'

function Show-MonitoringToolsBanner {
    Write-STDivider 'MONITORINGTOOLS MODULE LOADED' -Style heavy
    Write-STStatus "Run 'Get-Command -Module MonitoringTools' to view available tools." -Level SUB
    Write-STLog -Message 'MonitoringTools module loaded'
}

Show-MonitoringToolsBanner
