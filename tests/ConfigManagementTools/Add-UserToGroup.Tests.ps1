Describe 'Add-UserToGroup function' {
    BeforeAll {
        Import-Module $PSScriptRoot/../../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../../src/ConfigManagementTools/ConfigManagementTools.psd1 -Force
    }

    It 'passes parameters to Invoke-ScriptFile' {
        InModuleScope ConfigManagementTools {
            Mock Invoke-ScriptFile {} -ModuleName ConfigManagementTools
            Add-UserToGroup -CsvPath 'users.csv' -GroupName 'TeamA'
            Assert-MockCalled Invoke-ScriptFile -ModuleName ConfigManagementTools -Times 1 -ParameterFilter {
                $Name -eq 'AddUsersToGroup.ps1'
            }
        }
    }

    It 'accepts pipeline input' {
        InModuleScope ConfigManagementTools {
            Mock Invoke-ScriptFile {} -ModuleName ConfigManagementTools
            [pscustomobject]@{ CsvPath='input.csv'; GroupName='G1' } | Add-UserToGroup
            Assert-MockCalled Invoke-ScriptFile -ModuleName ConfigManagementTools -Times 1 -ParameterFilter {
                $Name -eq 'AddUsersToGroup.ps1'
            }
        }
    }

    It 'forwards transcript and switches' {
        InModuleScope ConfigManagementTools {
            Mock Invoke-ScriptFile {} -ModuleName ConfigManagementTools
            Add-UserToGroup -CsvPath 'users.csv' -GroupName 'G1' -TranscriptPath 't.log' -Simulate -Explain
            Assert-MockCalled Invoke-ScriptFile -ModuleName ConfigManagementTools -Times 1 -ParameterFilter {
                $TranscriptPath -eq 't.log' -and $Simulate -and $Explain
            }
        }
    }
}
