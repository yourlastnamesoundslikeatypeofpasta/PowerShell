. $PSScriptRoot/../TestHelpers.ps1

Describe 'Start-HealthMonitor and Stop-HealthMonitor' {
    Initialize-TestDrive
    BeforeAll {
        Import-Module $PSScriptRoot/../../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../../src/Telemetry/Telemetry.psd1 -Force
        Import-Module $PSScriptRoot/../../src/MonitoringTools/MonitoringTools.psd1 -Force
    }

    Safe-It 'exits when Stop-HealthMonitor is triggered' {
        InModuleScope MonitoringTools {
            $script:calls = 0
            Mock Write-STRichLog {} -ModuleName MonitoringTools
            Mock Get-SystemHealth {
                $script:calls++
                if ($script:calls -eq 3) { Stop-HealthMonitor }
                @{ CpuPercent = 0 }
            } -ModuleName MonitoringTools

            Start-HealthMonitor -IntervalSeconds 0

            Assert-MockCalled Write-STRichLog -ModuleName MonitoringTools -Times 3
        }
    }
}
