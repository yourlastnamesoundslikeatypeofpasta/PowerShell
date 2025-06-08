Describe 'Invoke-PerformanceAudit function' {
    BeforeAll {
        Import-Module $PSScriptRoot/../../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../../src/PerformanceTools/PerformanceTools.psd1 -Force
    }

    It 'forwards parameters to the script' {
        InModuleScope PerformanceTools {
            $scriptPath = Join-Path $PSScriptRoot 'Invoke-PerformanceAudit.ps1'
            Mock $scriptPath {}
            Invoke-PerformanceAudit -CpuThreshold 90 -MemoryThreshold 70 -TranscriptPath 't.log'
            Assert-MockCalled $scriptPath -Times 1 -ParameterFilter {
                $CpuThreshold -eq 90 -and $MemoryThreshold -eq 70 -and $TranscriptPath -eq 't.log'
            }
        }
    }
}
