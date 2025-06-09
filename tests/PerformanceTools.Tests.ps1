. $PSScriptRoot/TestHelpers.ps1
Describe 'PerformanceTools Module' {
    Initialize-TestDrive
    BeforeAll {
        Import-Module $PSScriptRoot/../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../src/PerformanceTools/PerformanceTools.psd1 -Force
    }

    Safe-It 'exports Measure-STCommand' {
        (Get-Command -Module PerformanceTools).Name | Should -Contain 'Measure-STCommand'
    }

    Safe-It 'exports Invoke-PerformanceAudit' {
        (Get-Command -Module PerformanceTools).Name | Should -Contain 'Invoke-PerformanceAudit'
    }

    Safe-It 'measures a script block' {
        $result = Measure-STCommand { Start-Sleep -Milliseconds 50 }
        $result.DurationSeconds | Should -BeGreaterThan 0
        $result.PSObject.Properties.Name | Should -Contain 'CpuSeconds'
        $result.PSObject.Properties.Name | Should -Contain 'MemoryDeltaMB'
    }

    Safe-It 'references bundled script path' {
        InModuleScope PerformanceTools {
            $definition = (Get-Command Invoke-PerformanceAudit).ScriptBlock.ToString()
            $definition | Should -Match 'Invoke-PerformanceAudit.ps1'
        }
    }
}
