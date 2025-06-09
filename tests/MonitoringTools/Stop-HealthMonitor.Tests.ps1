. $PSScriptRoot/../TestHelpers.ps1

Describe 'Stop-HealthMonitor function' {
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
}
