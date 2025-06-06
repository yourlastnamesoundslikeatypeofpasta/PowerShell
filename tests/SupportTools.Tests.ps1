Describe 'SupportTools Module' {
    BeforeAll {
        Import-Module $PSScriptRoot/../src/SupportTools/SupportTools.psd1 -Force
    }

    Context 'Exported commands' {
        $expected = @(
            'Add-UsersToGroup',
            'Clear-ArchiveFolder',
            'Clear-TempFiles',
            'Convert-ExcelToCsv',
            'Get-CommonSystemInfo',
            'Get-FailedLogins',
            'Get-NetworkShares',
            'Get-UniquePermissions',
            'Install-Fonts',
            'Invoke-PostInstall',
            'Export-ProductKey',
            'Invoke-DeploymentTemplate',
            'Search-ReadMe',
            'Set-ComputerIPAddress',
            'Set-NetAdapterMetering',
            'Set-TimeZoneEasternStandardTime',
            'Start-Countdown',
            'Update-Sysmon',
            'Set-SharedMailboxAutoReply',
            'Invoke-ExchangeCalendarManager',
            'Invoke-CompanyPlaceManagement'
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
            Add_UsersToGroup             = 'AddUsersToGroup.ps1'
            Clear_ArchiveFolder          = 'CleanupArchive.ps1'
            Clear_TempFiles              = 'CleanupTempFiles.ps1'
            Convert_ExcelToCsv           = 'Convert-ExcelToCsv.ps1'
            Get_CommonSystemInfo         = 'Get-CommonSystemInfo.ps1'
            Get_FailedLogins             = 'Get-FailedLogins.ps1'
            Get_NetworkShares            = 'Get-NetworkShares.ps1'
            Get_UniquePermissions        = 'Get-UniquePermissions.ps1'
            Install_Fonts                = 'Install-Fonts.ps1'
            Invoke_PostInstall           = 'PostInstallScript.ps1'
            Export_ProductKey            = 'ProductKey.ps1'
            Invoke_DeploymentTemplate    = 'SS_DEPLOYMENT_TEMPLATE.ps1'
            Search_ReadMe                = 'Search-ReadMe.ps1'
            Set_ComputerIPAddress        = 'Set-ComputerIPAddress.ps1'
            Set_NetAdapterMetering       = 'Set-NetAdapterMetering.ps1'
            Set_TimeZoneEasternStandardTime = 'Set-TimeZoneEasternStandardTime.ps1'
            Start_Countdown              = 'SimpleCountdown.ps1'
            Update_Sysmon                = 'Update-Sysmon.ps1'
        }

        $cases = foreach ($entry in $map.GetEnumerator()) {
            @{ Fn = $entry.Key.ToString().Replace('_','-') }
        }

        It 'calls Invoke-ScriptFile for <Fn>' -ForEach $cases {
            Mock Invoke-ScriptFile {} -ModuleName SupportTools
            & $Fn
            Assert-MockCalled Invoke-ScriptFile -ModuleName SupportTools -Times 1
        }

    }

    Context 'Add-UsersToGroup output passthrough' {
        It 'returns the object produced by the script' {
            InModuleScope SupportTools {
                $expected = [pscustomobject]@{ GroupName = 'MyGroup'; AddedUsers = @('a'); SkippedUsers = @('b') }
                Mock Invoke-ScriptFile { $expected }
                $result = Add-UsersToGroup -CsvPath 'users.csv' -GroupName 'MyGroup'
                $result | Should -Be $expected
            }
        }
    }
}
