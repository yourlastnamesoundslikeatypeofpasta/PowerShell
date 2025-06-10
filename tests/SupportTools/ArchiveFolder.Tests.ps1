. $PSScriptRoot/../TestHelpers.ps1
Describe 'Archive folder functions' {
    Initialize-TestDrive
    BeforeAll {
        Import-Module $PSScriptRoot/../../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../../src/SupportTools/SupportTools.psd1 -Force
    }

    Context 'Clear-ArchiveFolder' {
        Safe-It 'forwards parameters to script' {
            InModuleScope SupportTools {
                Mock Invoke-ScriptFile { 'ok' } -ModuleName SupportTools
                $res = Clear-ArchiveFolder -Arguments @('-SiteUrl','test') -TranscriptPath 't.log' -Simulate -Explain
                Assert-MockCalled Invoke-ScriptFile -ModuleName SupportTools -Times 1 -ParameterFilter {
                    $Name -eq 'CleanupArchive.ps1' -and
                    $Args -contains '-SiteUrl' -and
                    $Args -contains 'test' -and
                    $TranscriptPath -eq 't.log' -and
                    $Simulate -and $Explain
                }
                $res.Script | Should -Be 'CleanupArchive.ps1'
                $res.Result | Should -Be 'ok'
            }
        }
    }

    Context 'Restore-ArchiveFolder' {
        Safe-It 'forwards parameters to script' {
            InModuleScope SupportTools {
                Mock Invoke-ScriptFile { 'res' } -ModuleName SupportTools
                $res = Restore-ArchiveFolder -Arguments @('-SnapshotPath','snap.json') -TranscriptPath 'log.txt' -Simulate -Explain
                Assert-MockCalled Invoke-ScriptFile -ModuleName SupportTools -Times 1 -ParameterFilter {
                    $Name -eq 'RollbackArchive.ps1' -and
                    $Args -contains '-SnapshotPath' -and
                    $Args -contains 'snap.json' -and
                    $TranscriptPath -eq 'log.txt' -and
                    $Simulate -and $Explain
                }
                $res.Script | Should -Be 'RollbackArchive.ps1'
                $res.Result | Should -Be 'res'
            }
        }
    }
}
