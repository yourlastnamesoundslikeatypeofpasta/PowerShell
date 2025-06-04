Describe 'SupportTools Module' {
    BeforeAll {
        Import-Module $PSScriptRoot/../src/SupportTools/SupportTools.psd1 -Force
    }

    Context 'Exported commands' {
        $expected = @(
            'AddUsersToGroup',
            'CleanupArchive',
            'Convert-ExcelToCsv',
            'Get-CommonSystemInfo',
            'Get-FailedLogins',
            'Get-NetworkShares',
            'Get-UniquePermissions',
            'Install-Fonts',
            'PostInstallScript',
            'ProductKey',
            'Invoke-DeploymentTemplate',
            'Search-ReadMe',
            'Set-ComputerIPAddress',
            'Set-NetAdapterMetering',
            'Set-TimeZoneEasternStandardTime',
            'SimpleCountdown',
            'Update-Sysmon',
            'Invoke-ExchangeCalendarManager'
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
            AddUsersToGroup              = 'AddUsersToGroup.ps1'
            CleanupArchive               = 'CleanupArchive.ps1'
            Convert_ExcelToCsv           = 'Convert-ExcelToCsv.ps1'
            Get_CommonSystemInfo         = 'Get-CommonSystemInfo.ps1'
            Get_FailedLogins             = 'Get-FailedLogins.ps1'
            Get_NetworkShares            = 'Get-NetworkShares.ps1'
            Get_UniquePermissions        = 'Get-UniquePermissions.ps1'
            Install_Fonts                = 'Install-Fonts.ps1'
            PostInstallScript            = 'PostInstallScript.ps1'
            ProductKey                   = 'ProductKey.ps1'
            Invoke_DeploymentTemplate    = 'SS_DEPLOYMENT_TEMPLATE.ps1'
            Search_ReadMe                = 'Search-ReadMe.ps1'
            Set_ComputerIPAddress        = 'Set-ComputerIPAddress.ps1'
            Set_NetAdapterMetering       = 'Set-NetAdapterMetering.ps1'
            Set_TimeZoneEasternStandardTime = 'Set-TimeZoneEasternStandardTime.ps1'
            SimpleCountdown              = 'SimpleCountdown.ps1'
            Update_Sysmon                = 'Update-Sysmon.ps1'
        }

        foreach ($entry in $map.GetEnumerator()) {
            It "$($entry.Key) calls Invoke-ScriptFile" {
                Mock Invoke-ScriptFile {}
                & $entry.Key.ToString().Replace('_','-')
                Assert-MockCalled Invoke-ScriptFile -ParameterFilter { $Name -eq $entry.Value } -Times 1
            }
        }
    }
}
