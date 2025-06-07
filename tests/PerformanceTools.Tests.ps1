Describe 'PerformanceTools Module' {
    BeforeAll {
        Import-Module $PSScriptRoot/../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../src/PerformanceTools/PerformanceTools.psd1 -Force
    }

    It 'exports Measure-STCommand' {
        (Get-Command -Module PerformanceTools).Name | Should -Contain 'Measure-STCommand'
    }

    It 'measures a script block' {
        $result = Measure-STCommand { Start-Sleep -Milliseconds 50 }
        $result.DurationSeconds | Should -BeGreaterThan 0
        $result.PSObject.Properties.Name | Should -Contain 'CpuSeconds'
        $result.PSObject.Properties.Name | Should -Contain 'MemoryDeltaMB'
    }
}
