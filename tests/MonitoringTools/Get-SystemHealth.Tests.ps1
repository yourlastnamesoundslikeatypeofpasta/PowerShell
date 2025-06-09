. $PSScriptRoot/../TestHelpers.ps1
Describe 'Get-SystemHealth function' {
    BeforeAll {
        Import-Module $PSScriptRoot/../../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../../src/Telemetry/Telemetry.psd1 -Force
        Import-Module $PSScriptRoot/../../src/MonitoringTools/MonitoringTools.psd1 -Force
    }

    Safe-It 'returns expected health object' {
        Mock Get-CPUUsage { 42 } -ModuleName MonitoringTools
        $disk = @([pscustomobject]@{ Drive = 'C:'; SizeGB = 100; FreeGB = 50 })
        Mock Get-DiskSpaceInfo { $disk } -ModuleName MonitoringTools
        $events = @([pscustomobject]@{ Name = 'Error'; Count = 1 })
        Mock Get-EventLogSummary { $events } -ModuleName MonitoringTools

        $result = Get-SystemHealth
        $result.CpuPercent | Should -Be 42
        $result.DiskInfo | Should -Be $disk
        $result.EventLogSummary | Should -Be $events
    }
}
