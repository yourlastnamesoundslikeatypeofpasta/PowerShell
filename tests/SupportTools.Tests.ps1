Describe 'SupportTools Module' {
    BeforeAll {
        Import-Module $PSScriptRoot/../src/SupportTools/SupportTools.psd1 -Force
    }

    Context 'Exported commands' {
        $expected = @(
            'Add-UserToGroup',
            'Clear-ArchiveFolder',
            'Restore-ArchiveFolder',
            'Clear-TempFile',
            'Convert-ExcelToCsv',
            'Get-CommonSystemInfo',
            'Get-FailedLogin',
            'Get-NetworkShare',
            'Get-UniquePermission',
            'Install-Font',
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
            'Invoke-CompanyPlaceManagement',
            'Submit-SystemInfoTicket',
            'Generate-SPUsageReport'
            'Install-MaintenanceTasks'
            'Sync-SupportTools'
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
            Add_UserToGroup             = 'AddUsersToGroup.ps1'
            Clear_ArchiveFolder          = 'CleanupArchive.ps1'
            Restore_ArchiveFolder        = 'RollbackArchive.ps1'
            Clear_TempFile              = 'CleanupTempFiles.ps1'
            Convert_ExcelToCsv           = 'Convert-ExcelToCsv.ps1'
            Get_CommonSystemInfo         = 'Get-CommonSystemInfo.ps1'
            Get_FailedLogin             = 'Get-FailedLogins.ps1'
            Get_NetworkShare            = 'Get-NetworkShares.ps1'
            Get_UniquePermission        = 'Get-UniquePermissions.ps1'
            Install_Font                = 'Install-Fonts.ps1'
            Invoke_PostInstall           = 'PostInstallScript.ps1'
            Export_ProductKey            = 'ProductKey.ps1'
            Invoke_DeploymentTemplate    = 'SS_DEPLOYMENT_TEMPLATE.ps1'
            Search_ReadMe                = 'Search-ReadMe.ps1'
            Set_ComputerIPAddress        = 'Set-ComputerIPAddress.ps1'
            Set_NetAdapterMetering       = 'Set-NetAdapterMetering.ps1'
            Set_TimeZoneEasternStandardTime = 'Set-TimeZoneEasternStandardTime.ps1'
            Start_Countdown              = 'SimpleCountdown.ps1'
            Update_Sysmon                = 'Update-Sysmon.ps1'
            Submit_SystemInfoTicket      = 'Submit-SystemInfoTicket.ps1'
            Generate_SPUsageReport       = 'Generate-SPUsageReport.ps1'
            Install_MaintenanceTasks = 'Setup-ScheduledMaintenance.ps1'
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

    Context 'Add-UserToGroup output passthrough' {
        It 'returns the object produced by the script' {
            InModuleScope SupportTools {
                $expected = [pscustomobject]@{ GroupName = 'MyGroup'; AddedUsers = @('a'); SkippedUsers = @('b') }
                Mock Invoke-ScriptFile { $expected } -ModuleName SupportTools
                $result = Add-UserToGroup -CsvPath 'users.csv' -GroupName 'MyGroup'
                $result | Should -Be $expected
            }
        }
    }

    Context 'Set-SharedMailboxAutoReply behavior' {
        It 'defaults ExternalMessage to InternalMessage' {
            InModuleScope SupportTools {
                function Connect-ExchangeOnline {}
                function Disconnect-ExchangeOnline {}
                function Install-Module {}
                function Update-Module {}
                function Get-InstalledModule {}
                function Find-Module {}
                function Import-Module {}
                function global:Set-MailboxAutoReplyConfiguration {}
                function global:Get-MailboxAutoReplyConfiguration {}
                function global:Set-MailboxAutoReplyConfiguration {}
                function global:Get-MailboxAutoReplyConfiguration { 'result' }
                function Set-MailboxAutoReplyConfiguration {}
                function Get-MailboxAutoReplyConfiguration { 'result' }

                Mock Connect-ExchangeOnline {} -ModuleName SupportTools
                Mock Disconnect-ExchangeOnline {} -ModuleName SupportTools
                Mock Install-Module {} -ModuleName SupportTools
                Mock Update-Module {} -ModuleName SupportTools
                Mock Get-InstalledModule {} -ModuleName SupportTools
                Mock Find-Module {} -ModuleName SupportTools
                Mock Import-Module {} -ModuleName SupportTools
                Mock Set-MailboxAutoReplyConfiguration {} -ModuleName SupportTools
                Mock Get-MailboxAutoReplyConfiguration { 'result' } -ModuleName SupportTools

                $result = Set-SharedMailboxAutoReply -MailboxIdentity 'm' -StartTime (Get-Date) -EndTime (Get-Date).AddHours(1) -InternalMessage 'hello' -AdminUser 'admin'

                Assert-MockCalled Set-MailboxAutoReplyConfiguration -ParameterFilter { $ExternalMessage -eq 'hello' } -Times 1
                $result | Should -Be 'result'
            }
        }

        It 'uses web login when specified' {
            InModuleScope SupportTools {
                function Connect-ExchangeOnline {}
                function Disconnect-ExchangeOnline {}
                function Install-Module {}
                function Update-Module {}
                function Get-InstalledModule {}
                function Find-Module {}
                function Import-Module {}

                Mock Connect-ExchangeOnline {} -ModuleName SupportTools
                Mock Disconnect-ExchangeOnline {} -ModuleName SupportTools
                Mock Install-Module {} -ModuleName SupportTools
                Mock Update-Module {} -ModuleName SupportTools
                Mock Get-InstalledModule {} -ModuleName SupportTools
                Mock Find-Module {} -ModuleName SupportTools
                Mock Import-Module {} -ModuleName SupportTools
                Mock Set-MailboxAutoReplyConfiguration {} -ModuleName SupportTools
                Mock Get-MailboxAutoReplyConfiguration {} -ModuleName SupportTools

                Set-SharedMailboxAutoReply -MailboxIdentity 'm' -StartTime (Get-Date) -EndTime (Get-Date).AddHours(1) -InternalMessage 'i' -ExternalMessage 'e' -AdminUser 'admin' -UseWebLogin

                Assert-MockCalled Connect-ExchangeOnline -ParameterFilter { $UseWebLogin } -Times 1
            }
        }
    }

    Context 'Invoke-ExchangeCalendarManager behavior' {
        It 'connects to ExchangeOnline and exits when user quits' {
            InModuleScope SupportTools {
                function Connect-ExchangeOnline {}
                function Disconnect-ExchangeOnline {}
                function Install-Module {}
                function Update-Module {}
                function Get-InstalledModule {}
                function Find-Module {}
                function Import-Module {}
                function Read-Host { param([string]$Prompt) 'q' }

                Mock Connect-ExchangeOnline {} -ModuleName SupportTools
                Mock Disconnect-ExchangeOnline {} -ModuleName SupportTools
                Mock Install-Module {} -ModuleName SupportTools
                Mock Update-Module {} -ModuleName SupportTools
                Mock Get-InstalledModule {} -ModuleName SupportTools
                Mock Find-Module {} -ModuleName SupportTools
                Mock Import-Module {} -ModuleName SupportTools
                Mock Read-Host { 'q' } -ModuleName SupportTools

                Invoke-ExchangeCalendarManager

                Assert-MockCalled Connect-ExchangeOnline -Times 1
            }
        }
    }

    Context 'Invoke-CompanyPlaceManagement behavior' {
        It 'imports module when commands are missing' {
            InModuleScope SupportTools {
                function Get-Command {}
                function Import-Module {}
                function Connect-MicrosoftPlaces {}
                function Get-PlaceV3 { @() }
                function Write-Host {}

                Mock Get-Command { $null } -ModuleName SupportTools
                Mock Import-Module {} -ModuleName SupportTools
                Mock Connect-MicrosoftPlaces {} -ModuleName SupportTools
                Mock Get-PlaceV3 { @() } -ModuleName SupportTools
                Mock Write-Host {} -ModuleName SupportTools

                Invoke-CompanyPlaceManagement -Action Get -DisplayName 'b' -Type Building

                Assert-MockCalled Import-Module -Times 1
                Assert-MockCalled Connect-MicrosoftPlaces -Times 1
            }
        }

        It 'adds default floor when creating a building with AutoAddFloor' {
            InModuleScope SupportTools {
                function Get-Command {}
                function Connect-MicrosoftPlaces {}
                function Get-PlaceV3 { @() }
                function New-Place {}
                function Write-Host {}

                Mock Get-Command { @{ Name = 'Get-PlaceV3' } } -ModuleName SupportTools
                Mock Connect-MicrosoftPlaces {} -ModuleName SupportTools
                Mock Get-PlaceV3 { @() } -ModuleName SupportTools
                Mock New-Place {
                    if ($Type -eq 'Building') { return @{ PlaceId = '1' } }
                }
                Mock Write-Host {} -ModuleName SupportTools

                Invoke-CompanyPlaceManagement -Action Create -DisplayName 'B1' -Type Building -AutoAddFloor

                Assert-MockCalled New-Place -ParameterFilter { $Type -eq 'Floor' -and $Name -eq '1' } -Times 1
            }
        }
    }
}
