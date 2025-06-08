$PublicDir = Join-Path $PSScriptRoot 'Public'
$loggingModule = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath 'Logging/Logging.psd1'
$telemetryModule = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath 'Telemetry/Telemetry.psd1'
Import-Module $loggingModule -ErrorAction SilentlyContinue
Import-Module $telemetryModule -ErrorAction SilentlyContinue

Get-ChildItem -Path "$PublicDir/*.ps1" -ErrorAction SilentlyContinue | ForEach-Object { . $_.FullName }

Export-ModuleMember -Function 'Get-CPUUsage','Get-DiskSpaceInfo','Get-EventLogSummary','Get-SystemHealth'

function Show-MonitoringToolsBanner {
    <#
    .SYNOPSIS
        Displays the MonitoringTools module banner.
    #>
    [CmdletBinding()]
    param()
    Write-STDivider 'MONITORINGTOOLS MODULE LOADED' -Style heavy
    Write-STStatus "Run 'Get-Command -Module MonitoringTools' to view available tools." -Level SUB
    Write-STLog -Message 'MonitoringTools module loaded'
}

Show-MonitoringToolsBanner
