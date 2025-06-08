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

    Context 'Wrapper script invocation' {
        $map = @{
            Clear_ArchiveFolder       = 'CleanupArchive.ps1'
            Restore_ArchiveFolder     = 'RollbackArchive.ps1'
            Clear_TempFile           = 'CleanupTempFiles.ps1'
            Convert_ExcelToCsv        = 'Convert-ExcelToCsv.ps1'
            Get_UniquePermission     = 'Get-UniquePermissions.ps1'
            Export_ProductKey         = 'ProductKey.ps1'
            Search_ReadMe             = 'Search-ReadMe.ps1'
            Start_Countdown           = 'SimpleCountdown.ps1'
            New_SPUsageReport         = 'Generate-SPUsageReport.ps1'
            Invoke_JobBundle          = 'Run-JobBundle.ps1'
            Invoke_PerformanceAudit   = 'Invoke-PerformanceAudit.ps1'
        }

        $cases = foreach ($entry in $map.GetEnumerator()) {
            @{ Fn = $entry.Key.ToString().Replace('_','-') }
        }

        It 'calls Invoke-ScriptFile for <Fn>' -ForEach $cases {
            Mock Invoke-ScriptFile {} -ModuleName SupportTools
            switch ($Fn) {
                'Invoke-JobBundle' {
                    & $Fn -Path 'bundle.job.zip' -LogArchivePath 'out.zip'
                }
                Default {
                    & $Fn
                }
            }
            Assert-MockCalled Invoke-ScriptFile -ModuleName SupportTools -Times 1
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
