Describe 'MonitoringTools Module' {
    BeforeAll {
        Import-Module $PSScriptRoot/../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../src/Telemetry/Telemetry.psd1 -Force
        Import-Module $PSScriptRoot/../src/MonitoringTools/MonitoringTools.psd1 -Force
    }

    It 'exports Get-CPUUsage' {
        (Get-Command -Module MonitoringTools).Name | Should -Contain 'Get-CPUUsage'
    }

    It 'exports Get-SystemHealth' {
        (Get-Command -Module MonitoringTools).Name | Should -Contain 'Get-SystemHealth'
    }

    It 'returns system health object' {
        Mock Get-CPUUsage { 10 } -ModuleName MonitoringTools
        Mock Get-DiskSpaceInfo { @() } -ModuleName MonitoringTools
        Mock Get-EventLogSummary { @() } -ModuleName MonitoringTools
        $result = Get-SystemHealth
        $result.CpuPercent | Should -Be 10
        $result.DiskInfo   | Should -Be @()
    }
}
