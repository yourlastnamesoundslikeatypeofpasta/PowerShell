Describe 'Invoke-NewHireUserAutomation function' {
    BeforeAll {
        Import-Module $PSScriptRoot/../../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../../src/SupportTools/SupportTools.psd1 -Force
    }

    It 'passes parameters to Invoke-ScriptFile' {
        InModuleScope SupportTools {
            Mock Invoke-ScriptFile {} -ModuleName SupportTools
            Invoke-NewHireUserAutomation -PollMinutes 1 -Once -TranscriptPath 't.log'
            Assert-MockCalled Invoke-ScriptFile -ModuleName SupportTools -Times 1 -ParameterFilter {
                $Name -eq 'Create-NewHireUser.ps1' -and $Args -contains '-Once'
            }
        }
    }
}
