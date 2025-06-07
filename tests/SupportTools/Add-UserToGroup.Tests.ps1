Describe 'Add-UserToGroup function' {
    BeforeAll {
        Import-Module $PSScriptRoot/../../src/SupportTools/SupportTools.psd1 -Force
    }
    InModuleScope SupportTools {
        It 'passes parameters to Invoke-ScriptFile' {
            Mock Invoke-ScriptFile {} -ModuleName SupportTools
            Add-UserToGroup -CsvPath 'users.csv' -GroupName 'TeamA'
            Assert-MockCalled Invoke-ScriptFile -ModuleName SupportTools -Times 1 -ParameterFilter {
                $Name -eq 'AddUsersToGroup.ps1' -and
                $Args -eq @('-CsvPath','users.csv','-GroupName','TeamA')
            }
        }

        It 'accepts pipeline input' {
            Mock Invoke-ScriptFile {} -ModuleName SupportTools
            [pscustomobject]@{ CsvPath='input.csv'; GroupName='G1' } | Add-UserToGroup
            Assert-MockCalled Invoke-ScriptFile -ModuleName SupportTools -Times 1 -ParameterFilter {
                $Args -eq @('-CsvPath','input.csv','-GroupName','G1')
            }
        }

        It 'forwards transcript and switches' {
            Mock Invoke-ScriptFile {} -ModuleName SupportTools
            Add-UserToGroup -TranscriptPath 't.log' -Simulate -Explain
            Assert-MockCalled Invoke-ScriptFile -ModuleName SupportTools -Times 1 -ParameterFilter {
                $TranscriptPath -eq 't.log' -and $Simulate -and $Explain
            }
        }
    }
}
