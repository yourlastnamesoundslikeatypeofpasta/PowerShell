. $PSScriptRoot/../TestHelpers.ps1
Describe 'Measure-STCommand function' {
    Initialize-TestDrive
    BeforeAll {
        Import-Module $PSScriptRoot/../../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../../src/PerformanceTools/PerformanceTools.psd1 -Force
        InModuleScope PerformanceTools { function Send-STMetric {} }
    }

    Safe-It 'returns timing metrics' {
        InModuleScope PerformanceTools {
            function Send-STMetric {}
            Mock Write-STStatus {}
            $result = Measure-STCommand -ScriptBlock { Start-Sleep -Milliseconds 5 }
            $result | Should -Not -BeNull
            $result.DurationSeconds | Should -BeGreaterThan 0
            $result.CpuSeconds | Should -BeGreaterOrEqual 0
        }
    }

    Safe-It 'writes status messages when not quiet' {
        InModuleScope PerformanceTools {
            function Send-STMetric {}
            Mock Write-STStatus {} -Verifiable
            Measure-STCommand -ScriptBlock { }
            Assert-MockCalled Write-STStatus -Times 3
        }
    }

    Safe-It 'suppresses status when Quiet' {
        InModuleScope PerformanceTools {
            function Send-STMetric {}
            Mock Write-STStatus {}
            Measure-STCommand -ScriptBlock { } -Quiet
            Assert-MockCalled Write-STStatus -Times 0
        }
    }

    Safe-It 'throws when ScriptBlock is null' {
        InModuleScope PerformanceTools {
            { Measure-STCommand -ScriptBlock $null } | Should -Throw 'ScriptBlock'
        }
    }

    Safe-It 'returns consistent structure across runs' {
        InModuleScope PerformanceTools {
            function Send-STMetric {}
            Mock Write-STStatus {}
            $first = Measure-STCommand -ScriptBlock { Start-Sleep -Milliseconds 5 }
            $second = Measure-STCommand -ScriptBlock { Start-Sleep -Milliseconds 5 }
            $first.PSObject.Properties.Name | Should -Be $second.PSObject.Properties.Name
        }
    }
}
