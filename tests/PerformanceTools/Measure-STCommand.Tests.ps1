Describe 'Measure-STCommand function' {
    BeforeAll {
        Import-Module $PSScriptRoot/../../src/PerformanceTools/PerformanceTools.psd1 -Force
    }

    It 'returns timing metrics' {
        InModuleScope PerformanceTools {
            Mock Write-STStatus {}
            $result = Measure-STCommand -ScriptBlock { Start-Sleep -Milliseconds 5 }
            $result | Should -Not -BeNull
            $result.DurationSeconds | Should -BeGreaterThan 0
            $result.CpuSeconds | Should -BeGreaterOrEqual 0
        }
    }

    It 'writes status messages when not quiet' {
        InModuleScope PerformanceTools {
            Mock Write-STStatus {} -Verifiable
            Measure-STCommand -ScriptBlock { }
            Assert-MockCalled Write-STStatus -Times 3
        }
    }

    It 'suppresses status when Quiet' {
        InModuleScope PerformanceTools {
            Mock Write-STStatus {}
            Measure-STCommand -ScriptBlock { } -Quiet
            Assert-MockCalled Write-STStatus -Times 0
        }
    }
}
