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

    Context 'Logging' {
        It 'logs CPU usage' {
            Mock Write-STRichLog {} -ModuleName MonitoringTools
            Mock Get-Counter { [pscustomobject]@{ CounterSamples = @([pscustomobject]@{ CookedValue = 10 }) } } -ModuleName MonitoringTools -Verifiable
            Get-CPUUsage | Out-Null
            Assert-MockCalled Write-STRichLog -ModuleName MonitoringTools -ParameterFilter { $Tool -eq 'Get-CPUUsage' } -Times 1
        }

        It 'logs disk info' {
            Mock Write-STRichLog {} -ModuleName MonitoringTools
            Mock Get-CimInstance { @() } -ModuleName MonitoringTools
            Get-DiskSpaceInfo | Out-Null
            Assert-MockCalled Write-STRichLog -ModuleName MonitoringTools -ParameterFilter { $Tool -eq 'Get-DiskSpaceInfo' } -Times 1
        }

        It 'logs event log summary' {
            Mock Write-STRichLog {} -ModuleName MonitoringTools
            Mock Get-WinEvent { @() } -ModuleName MonitoringTools
            Get-EventLogSummary | Out-Null
            Assert-MockCalled Write-STRichLog -ModuleName MonitoringTools -ParameterFilter { $Tool -eq 'Get-EventLogSummary' } -Times 1
        }

        It 'logs system health' {
            Mock Write-STRichLog {} -ModuleName MonitoringTools
            Mock Get-CPUUsage { 10 } -ModuleName MonitoringTools
            Mock Get-DiskSpaceInfo { @() } -ModuleName MonitoringTools
            Mock Get-EventLogSummary { @() } -ModuleName MonitoringTools
            Get-SystemHealth | Out-Null
            Assert-MockCalled Write-STRichLog -ModuleName MonitoringTools -ParameterFilter { $Tool -eq 'Get-SystemHealth' } -Times 1
        }
    }
}
