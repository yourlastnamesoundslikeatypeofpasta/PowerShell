. $PSScriptRoot/../TestHelpers.ps1

Describe 'Get-CPUUsage function' {
    BeforeAll {
        Import-Module $PSScriptRoot/../../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../../src/Telemetry/Telemetry.psd1 -Force
        Import-Module $PSScriptRoot/../../src/MonitoringTools/MonitoringTools.psd1 -Force
    }

    Safe-It 'returns average percentage when Get-Counter is available' {
        InModuleScope MonitoringTools {
            Mock Get-Command { @{ Name = 'Get-Counter' } } -ParameterFilter { $Name -eq 'Get-Counter' }
            $samples = 1..3 | ForEach-Object { [pscustomobject]@{ CookedValue = 10 } }
            Mock Get-Counter { @{ CounterSamples = $samples } }
            Mock Write-STRichLog {}
            $result = Get-CPUUsage
            $result | Should -Be 10
        }
    }

    Safe-It 'logs warning when counter cmdlet missing' {
        InModuleScope MonitoringTools {
            Mock Get-Command { $null } -ParameterFilter { $Name -eq 'Get-Counter' }
            Mock Write-STStatus {}
            Mock Write-STRichLog {}
            $null = Get-CPUUsage
            Assert-MockCalled Write-STStatus -Times 1
        }
    }
}
