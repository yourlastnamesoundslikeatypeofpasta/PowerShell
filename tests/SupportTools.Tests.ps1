. $PSScriptRoot/TestHelpers.ps1
Describe 'SupportTools Module' {
    Initialize-TestDrive
    BeforeAll {
        Import-Module $PSScriptRoot/../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../src/Telemetry/Telemetry.psd1 -Force
        Import-Module $PSScriptRoot/../src/SharePointTools/SharePointTools.psd1 -Force
        Import-Module $PSScriptRoot/../src/ServiceDeskTools/ServiceDeskTools.psd1 -Force
        Import-Module $PSScriptRoot/../src/SupportTools/SupportTools.psd1 -Force
    }

    Context 'Exported commands' {
        $expected = @(
            'Clear-ArchiveFolder',
            'Restore-ArchiveFolder',
            'Clear-TempFile',
            'Convert-ExcelToCsv',
            'Get-UniquePermission',
            'Export-ProductKey',
            'Search-ReadMe',
            'Start-Countdown',
            'Export-ITReport',
            'New-SPUsageReport',
            'New-STDashboard',
            'Invoke-NewHireUserAutomation'
            'Sync-SupportTools',
            'Invoke-JobBundle',
            'Invoke-PerformanceAudit'
        )

        $exported = (Get-Command -Module SupportTools).Name
        foreach ($cmd in $expected) {
            Safe-It "Exports $cmd" {
                $exported | Should -Contain $cmd
            }
        }
    }


    Context 'Sync-SupportTools behavior' {
        Safe-It 'clones when repository is missing' {
            InModuleScope SupportTools {
                function git {}
                function Import-Module {}
                Mock git {} -ModuleName SupportTools
                Mock Import-Module {} -ModuleName SupportTools
                $path = Join-Path ([IO.Path]::GetTempPath()) ([guid]::NewGuid())
                Sync-SupportTools -RepositoryUrl 'url' -InstallPath $path
                Assert-MockCalled git -ModuleName SupportTools -Times 1 -ParameterFilter { $args[0] -eq 'clone' }
            }
        }

        Safe-It 'pulls when repository exists' {
            InModuleScope SupportTools {
                function git {}
                function Import-Module {}
                Mock git {} -ModuleName SupportTools
                Mock Import-Module {} -ModuleName SupportTools
                $path = Join-Path ([IO.Path]::GetTempPath()) ([guid]::NewGuid())
                New-Item -ItemType Directory -Path (Join-Path $path '.git') -Force | Out-Null
                Sync-SupportTools -RepositoryUrl 'url' -InstallPath $path
                Assert-MockCalled git -ModuleName SupportTools -Times 1 -ParameterFilter { $args[0] -eq '-C' -and $args[2] -eq 'pull' }
            }
        }

        Safe-It 'records transcript when path provided' {
            InModuleScope SupportTools {
                function git {}
                function Import-Module {}
                function Start-Transcript {}
                function Stop-Transcript {}
                Mock git {} -ModuleName SupportTools
                Mock Import-Module {} -ModuleName SupportTools
                Mock Start-Transcript {} -ModuleName SupportTools
                Mock Stop-Transcript {} -ModuleName SupportTools
                $path = Join-Path ([IO.Path]::GetTempPath()) ([guid]::NewGuid())
                Sync-SupportTools -RepositoryUrl 'url' -InstallPath $path -TranscriptPath 't.log'
                Assert-MockCalled Start-Transcript -ModuleName SupportTools -Times 1 -ParameterFilter { $Path -eq 't.log' -and $Append }
                Assert-MockCalled Stop-Transcript -ModuleName SupportTools -Times 1
            }
        }
    }

    Context 'Search-ReadMe transcript' {
        Safe-It 'starts and stops transcript when path is given' {
            InModuleScope SupportTools {
                function Start-Transcript {}
                function Stop-Transcript {}
                Mock Start-Transcript {} -ModuleName SupportTools
                Mock Stop-Transcript {} -ModuleName SupportTools
                Search-ReadMe -TranscriptPath 'log.txt' | Out-Null
                Assert-MockCalled Start-Transcript -ModuleName SupportTools -Times 1 -ParameterFilter { $Path -eq 'log.txt' -and $Append }
                Assert-MockCalled Stop-Transcript -ModuleName SupportTools -Times 1
            }
        }
    }

    Context 'Error handling' {
        Safe-It 'returns error record when git fails' {
            InModuleScope SupportTools {
                function git { throw 'git fail' }
                $res = Sync-SupportTools -RepositoryUrl 'url' -InstallPath 'path'
                $res | Should -BeOfType 'System.Management.Automation.ErrorRecord'
                $res.Exception.Message | Should -Be 'git fail'
            }
        }

        Safe-It 'returns error record when search fails' {
            InModuleScope SupportTools {
                function Get-ChildItem { throw 'bad' }
                $res = Search-ReadMe
                $res | Should -BeOfType 'System.Management.Automation.ErrorRecord'
            }
        }
    }
}
