Describe 'MonitoringTools Module' {
    BeforeAll {
        Import-Module $PSScriptRoot/../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../src/MonitoringTools/MonitoringTools.psd1 -Force
    }

    It 'exports expected commands' {
        $expected = 'Get-DiskSpace','Get-CPUUsage','Get-SystemEventLogs','Get-SystemHealth','Get-CommonSystemInfo'
        (Get-Command -Module MonitoringTools).Name | Should -BeLike '*'
        foreach ($cmd in $expected) {
            (Get-Command -Module MonitoringTools).Name | Should -Contain $cmd
        }
    }

    It 'returns CPU usage value' {
        InModuleScope MonitoringTools {
            function Get-Counter { param([string]$CounterPath,[int]$SampleInterval,[int]$MaxSamples); [pscustomobject]@{ CounterSamples = @([pscustomobject]@{ CookedValue = 5 }) } }
            $usage = Get-CPUUsage -Samples 1
            $usage | Should -Be 5
        }
    }
}
