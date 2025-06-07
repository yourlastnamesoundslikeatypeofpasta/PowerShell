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
            'Invoke-IncidentResponse',
            'Submit-SystemInfoTicket',
            'New-SPUsageReport'
            'Install-MaintenanceTasks'
            'Invoke-GroupMembershipCleanup',
            'Sync-SupportTools',
            'Invoke-JobBundle',
            'Invoke-PerformanceAudit',
            'Invoke-FullSystemAudit'
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
            Invoke_IncidentResponse      = 'Invoke-IncidentResponse.ps1'
            Submit_SystemInfoTicket      = 'Submit-SystemInfoTicket.ps1'
            New_SPUsageReport            = 'Generate-SPUsageReport.ps1'
            Install_MaintenanceTasks = 'Setup-ScheduledMaintenance.ps1'
            Invoke_GroupMembershipCleanup = 'CleanupGroupMembership.ps1'
            Invoke_JobBundle = 'Run-JobBundle.ps1'
            Invoke_PerformanceAudit = 'Invoke-PerformanceAudit.ps1'
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
                'Submit-SystemInfoTicket' {
                    & $Fn -SiteName 'SiteA' -RequesterEmail 'user@example.com'
                }
                'Set-SharedMailboxAutoReply' {
                    $now = Get-Date
                    & $Fn -MailboxIdentity 'box' -StartTime $now -EndTime $now.AddDays(1) -InternalMessage 'hi' -AdminUser 'admin@example.com'
                }
                'Invoke-CompanyPlaceManagement' {
                    & $Fn -Action 'Get' -DisplayName 'Place'
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

    Context 'Get-CommonSystemInfo collection' {
        It 'returns system information object' {
            InModuleScope SupportTools {
                function Get-CimInstance {
                    param($ClassName)
                }
                Mock Get-CimInstance {
                    switch ($ClassName) {
                        'Win32_OperatingSystem' { [pscustomobject]@{ CSName='PC'; Caption='OS'; BuildNumber='1'; TotalVisibleMemorySize=1048576 } }
                        'Win32_Processor'       { [pscustomobject]@{ Name='CPU' } }
                        'Win32_LogicalDisk'     { [pscustomobject]@{ DeviceID='C:'; Size=1073741824; FreeSpace=536870912 } }
                        'Win32_PhysicalMemory'  { $null }
                    }
                } -ModuleName SupportTools
                Mock Import-Module {} -ModuleName SupportTools
                Mock Write-STStatus {} -ModuleName SupportTools

                $result = Get-CommonSystemInfo

                $result.ComputerName | Should -Be 'PC'
                $result.OSVersion    | Should -Be 'OS'
                $result.OSBuild      | Should -Be '1'
                $result.Processor    | Should -Be 'CPU'
                $result.Memory       | Should -Be (1048576 / 1MB)
                $result.DiskSpace    | Should -Not -BeNullOrEmpty
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

                Assert-MockCalled Set-MailboxAutoReplyConfiguration -ParameterFilter {
                    ($idx = [array]::IndexOf($args, '-ExternalMessage')) -ge 0 -and $args[$idx + 1] -eq 'hello'
                } -Times 1
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
                function Set-MailboxAutoReplyConfiguration {}
                function Get-MailboxAutoReplyConfiguration {}

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

                Assert-MockCalled Connect-ExchangeOnline -ParameterFilter { $args -contains '-UseWebLogin' } -Times 1
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
                function New-Place { param($Type, $Name, $ParentId) }
                function Write-Host {}

                Mock Get-Command { @{ Name = 'Get-PlaceV3' } } -ModuleName SupportTools
                Mock Connect-MicrosoftPlaces {} -ModuleName SupportTools
                Mock Get-PlaceV3 { @() } -ModuleName SupportTools
                Mock New-Place {
                    if ($Type -eq 'Building') { return @{ PlaceId = '1' } }
                } -ModuleName SupportTools
                Mock Write-Host {} -ModuleName SupportTools

                Invoke-CompanyPlaceManagement -Action Create -DisplayName 'B1' -Type Building -AutoAddFloor

                Assert-MockCalled New-Place -ParameterFilter { $Type -eq 'Floor' -and $Name -eq '1' } -Times 1
            }
        }
    }
}
