. $PSScriptRoot/../TestHelpers.ps1

Describe 'Stop-HealthMonitor function' {
    Initialize-TestDrive
    BeforeAll {
        Import-Module $PSScriptRoot/../../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../../src/Telemetry/Telemetry.psd1 -Force
        Import-Module $PSScriptRoot/../../src/MonitoringTools/MonitoringTools.psd1 -Force
    }

    Safe-It 'sets script flag to stop monitoring' {
        InModuleScope MonitoringTools {
            $script:StopHealthMonitor = $false
            Stop-HealthMonitor
            $script:StopHealthMonitor | Should -BeTrue
        }
    }

    Safe-It 'does not set flag when -WhatIf specified' {
        InModuleScope MonitoringTools {
            $script:StopHealthMonitor = $false
            Stop-HealthMonitor -WhatIf
            $script:StopHealthMonitor | Should -BeFalse
        }
    }

    Safe-It 'stops logging when called mid-loop' {
        InModuleScope MonitoringTools {
            $script:calls = 0
            $script:StopHealthMonitor = $false
            Mock Write-STRichLog {} -ModuleName MonitoringTools
            Mock Start-Sleep {} -ModuleName MonitoringTools
            Mock Get-SystemHealth {
                $script:calls++
                if ($script:calls -eq 2) { Stop-HealthMonitor }
                @{ CpuPercent = 0 }
            } -ModuleName MonitoringTools

            Start-HealthMonitor -IntervalSeconds 0 -Count 5

            Assert-MockCalled Write-STRichLog -ModuleName MonitoringTools -Times 2
        }
    }
}
