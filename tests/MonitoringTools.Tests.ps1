. $PSScriptRoot/TestHelpers.ps1
Describe 'MonitoringTools Module' {
    BeforeAll {
        Import-Module $PSScriptRoot/../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../src/Telemetry/Telemetry.psd1 -Force
        Import-Module $PSScriptRoot/../src/MonitoringTools/MonitoringTools.psd1 -Force
    }

    Safe-It 'exports Get-CPUUsage' {
        (Get-Command -Module MonitoringTools).Name | Should -Contain 'Get-CPUUsage'
    }

    Safe-It 'exports Get-SystemHealth' {
        (Get-Command -Module MonitoringTools).Name | Should -Contain 'Get-SystemHealth'
    }

    Safe-It 'exports Start-HealthMonitor' {
        (Get-Command -Module MonitoringTools).Name | Should -Contain 'Start-HealthMonitor'
    }

    Safe-It 'returns system health object' {
        Mock Get-CPUUsage { 10 } -ModuleName MonitoringTools
        Mock Get-DiskSpaceInfo { @() } -ModuleName MonitoringTools
        Mock Get-EventLogSummary { @() } -ModuleName MonitoringTools
        $result = Get-SystemHealth
        $result.CpuPercent | Should -Be 10
        $result.DiskInfo   | Should -Be @()
    }

    Safe-It 'logs health samples on a loop' {
        Mock Get-SystemHealth { @{ CpuPercent = 1; DiskInfo = @(); EventLogSummary = @() } } -ModuleName MonitoringTools
        Mock Write-STRichLog {} -ModuleName MonitoringTools
        Start-HealthMonitor -IntervalSeconds 0 -Count 2
        Assert-MockCalled Write-STRichLog -ModuleName MonitoringTools -Times 10
    }

    Safe-It 'writes logs to a specified file' {
        Mock Get-CPUUsage { 1 } -ModuleName MonitoringTools
        Mock Get-DiskSpaceInfo { @() } -ModuleName MonitoringTools
        Mock Get-EventLogSummary { @() } -ModuleName MonitoringTools
        $logFile = Join-Path $TestDrive 'health.log'
        Start-HealthMonitor -IntervalSeconds 0 -Count 1 -LogPath $logFile
        Test-Path $logFile | Should -Be $true
        (Get-Content $logFile | Measure-Object).Count | Should -Be 5
    }
}
