. $PSScriptRoot/../TestHelpers.ps1
Describe 'Add-UserToGroup function' {
    Initialize-TestDrive
    BeforeAll {
        Import-Module $PSScriptRoot/../../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../../src/ConfigManagementTools/ConfigManagementTools.psd1 -Force
    }

    Safe-It 'passes parameters to Invoke-ScriptFile' {
        InModuleScope ConfigManagementTools {
            Mock Invoke-ScriptFile {} -ModuleName ConfigManagementTools
            Add-UserToGroup -CsvPath 'users.csv' -GroupName 'TeamA'
            Assert-MockCalled Invoke-ScriptFile -ModuleName ConfigManagementTools -Times 1 -ParameterFilter {
                $Name -eq 'AddUsersToGroup.ps1'
            }
        }
    }

    Safe-It 'accepts pipeline input' {
        InModuleScope ConfigManagementTools {
            Mock Invoke-ScriptFile {} -ModuleName ConfigManagementTools
            [pscustomobject]@{ CsvPath='input.csv'; GroupName='G1' } | Add-UserToGroup
            Assert-MockCalled Invoke-ScriptFile -ModuleName ConfigManagementTools -Times 1 -ParameterFilter {
                $Name -eq 'AddUsersToGroup.ps1'
            }
        }
    }

    Safe-It 'forwards transcript and switches' {
        InModuleScope ConfigManagementTools {
            Mock Invoke-ScriptFile {} -ModuleName ConfigManagementTools
            Add-UserToGroup -CsvPath 'users.csv' -GroupName 'G1' -TranscriptPath 't.log' -Simulate -Explain
            Assert-MockCalled Invoke-ScriptFile -ModuleName ConfigManagementTools -Times 1 -ParameterFilter {
                $TranscriptPath -eq 't.log' -and $Simulate -and $Explain
            }
        }
    }

    Safe-It 'passes Cloud parameter' {
        InModuleScope ConfigManagementTools {
            Mock Invoke-ScriptFile {} -ModuleName ConfigManagementTools
            Add-UserToGroup -CsvPath 'users.csv' -GroupName 'G1' -Cloud 'AD'
            Assert-MockCalled Invoke-ScriptFile -ModuleName ConfigManagementTools -Times 1 -ParameterFilter {
                $Arguments -contains '-Cloud' -and $Arguments -contains 'AD'
            }
        }
    }

    Safe-It 'returns error record on failure' {
        InModuleScope ConfigManagementTools {
            function Invoke-ScriptFile { throw 'oops' }
            $res = Add-UserToGroup -CsvPath 'u.csv' -GroupName 'G1'
            $res | Should -BeOfType 'System.Management.Automation.ErrorRecord'
            $res.Exception.Message | Should -Be 'oops'
        }
    }
}
