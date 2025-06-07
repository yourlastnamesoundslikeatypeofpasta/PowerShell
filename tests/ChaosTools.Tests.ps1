Describe 'ChaosTools Module' {
    BeforeAll {
        Import-Module $PSScriptRoot/../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../src/Telemetry/Telemetry.psd1 -Force
        Import-Module $PSScriptRoot/../src/ChaosTools/ChaosTools.psd1 -Force
    }

    It 'exports Invoke-ChaosTest' {
        (Get-Command -Module ChaosTools).Name | Should -Contain 'Invoke-ChaosTest'
    }

    It 'runs without error when ChaosMode disabled' {
        InModuleScope ChaosTools {
            Invoke-ChaosTest -Iterations 1 -MaxDelaySeconds 0 -FailureRate 0
        }
    }
}
