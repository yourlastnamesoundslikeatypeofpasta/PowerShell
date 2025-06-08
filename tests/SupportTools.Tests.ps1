Describe 'SupportTools Module' {
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
            'New-SPUsageReport'
            'Sync-SupportTools',
            'Invoke-JobBundle',
            'Invoke-PerformanceAudit'
        )

        $exported = (Get-Command -Module SupportTools).Name
        foreach ($cmd in $expected) {
            It "Exports $cmd" {
                $exported | Should -Contain $cmd
            }
        }
    }


    Context 'Sync-SupportTools behavior' {
        It 'clones when repository is missing' {
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

        It 'pulls when repository exists' {
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
    }

}
