$PublicDir = Join-Path $PSScriptRoot 'Public'
$loggingModule = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath 'Logging/Logging.psd1'
$telemetryModule = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath 'Telemetry/Telemetry.psd1'
Import-Module $loggingModule -Force -ErrorAction SilentlyContinue -DisableNameChecking
Import-Module $telemetryModule -Force -ErrorAction SilentlyContinue -DisableNameChecking

Get-ChildItem -Path "$PublicDir/*.ps1" -ErrorAction SilentlyContinue | ForEach-Object { . $_.FullName }

Export-ModuleMember -Function 'Get-CPUUsage', 'Get-DiskSpaceInfo', 'Get-EventLogSummary', 'Get-SystemHealth', 'Start-HealthMonitor', 'Stop-HealthMonitor'

function Show-MonitoringToolsBanner {
    <#
    .SYNOPSIS
        Returns MonitoringTools module metadata for banner display.
    #>
    [CmdletBinding()]
    param()
    $manifestPath = Join-Path $PSScriptRoot 'MonitoringTools.psd1'
    [pscustomobject]@{
        Module  = 'MonitoringTools'
        Version = (Import-PowerShellDataFile $manifestPath).ModuleVersion
    }
}
