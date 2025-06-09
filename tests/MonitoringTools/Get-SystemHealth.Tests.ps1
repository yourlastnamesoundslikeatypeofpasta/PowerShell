. $PSScriptRoot/../TestHelpers.ps1
Describe 'Get-SystemHealth function' {
    Initialize-TestDrive
    BeforeAll {
        Import-Module $PSScriptRoot/../../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../../src/Telemetry/Telemetry.psd1 -Force
        Import-Module $PSScriptRoot/../../src/MonitoringTools/MonitoringTools.psd1 -Force
    }

    Safe-It 'returns expected health object' {
        Mock Get-CPUUsage { 42 } -ModuleName MonitoringTools
        $disk = @([pscustomobject]@{ Drive='C:'; SizeGB=100; FreeGB=50 })
        Mock Get-DiskSpaceInfo { $disk } -ModuleName MonitoringTools
        $events = @([pscustomobject]@{ Name='Error'; Count=1 })
        Mock Get-EventLogSummary { $events } -ModuleName MonitoringTools

        $result = Get-SystemHealth
        $result.CpuPercent | Should -Be 42
        $result.DiskInfo | Should -Be $disk
        $result.EventLogSummary | Should -Be $events
    }

    Safe-It 'does not query health when -WhatIf specified' {
        Mock Get-CPUUsage {} -ModuleName MonitoringTools
        Mock Get-DiskSpaceInfo {} -ModuleName MonitoringTools
        Mock Get-EventLogSummary {} -ModuleName MonitoringTools

        Get-SystemHealth -WhatIf

        Assert-MockCalled Get-CPUUsage -Times 0 -ModuleName MonitoringTools
        Assert-MockCalled Get-DiskSpaceInfo -Times 0 -ModuleName MonitoringTools
        Assert-MockCalled Get-EventLogSummary -Times 0 -ModuleName MonitoringTools
    }
}
