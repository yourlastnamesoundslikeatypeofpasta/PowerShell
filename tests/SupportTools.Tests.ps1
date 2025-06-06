Describe 'SupportTools Module' {
    BeforeAll {
        Import-Module $PSScriptRoot/../src/SupportTools/SupportTools.psd1 -Force
    }

    Context 'Exported commands' {
        $expected = @(
            'Add-UsersToGroup',
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
            'Set-SharedMailboxAutoReply',
            'Invoke-ExchangeCalendarManager'
        )

        $exported = (Get-Command -Module SupportTools).Name
        foreach ($cmd in $expected) {
            It "Exports $cmd" {
                $exported | Should -Contain $cmd
            }
        }
    }

}
