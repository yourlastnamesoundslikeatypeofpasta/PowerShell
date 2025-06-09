. $PSScriptRoot/../TestHelpers.ps1

Describe 'ConfigManagementTools public functions' {
    BeforeAll {
        Import-Module $PSScriptRoot/../../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../../src/ConfigManagementTools/ConfigManagementTools.psd1 -Force
    }

    $wrappers = @{
        'Install-Font'                    = 'Install-Fonts.ps1'
        'Install-MaintenanceTasks'        = 'Setup-ScheduledMaintenance.ps1'
        'Invoke-DeploymentTemplate'       = 'SS_DEPLOYMENT_TEMPLATE.ps1'
        'Invoke-PostInstall'              = 'PostInstallScript.ps1'
        'Set-ComputerIPAddress'           = 'Set-ComputerIPAddress.ps1'
        'Set-NetAdapterMetering'          = 'Set-NetAdapterMetering.ps1'
        'Set-TimeZoneEasternStandardTime' = 'Set-TimeZoneEasternStandardTime.ps1'
    }

    Safe-It 'calls Invoke-ScriptFile' -ForEach $wrappers.GetEnumerator() {
        param($case)
        InModuleScope ConfigManagementTools {
            Mock Invoke-ScriptFile {} -ModuleName ConfigManagementTools
            if ($case.Key -eq 'Install-MaintenanceTasks') {
                & $case.Key -Register
            }
            else {
                & $case.Key
            }
            Assert-MockCalled Invoke-ScriptFile -ModuleName ConfigManagementTools -Times 1 -ParameterFilter { $Name -eq $case.Value }
        }
    }

    Safe-It 'throws when Invoke-ScriptFile fails' -ForEach $wrappers.GetEnumerator() {
        param($case)
        InModuleScope ConfigManagementTools {
            Mock Invoke-ScriptFile { throw 'bad' } -ModuleName ConfigManagementTools
            { if ($case.Key -eq 'Install-MaintenanceTasks') { & $case.Key -Register } else { & $case.Key } } | Should -Throw
        }
    }

    Context 'Invoke-GroupMembershipCleanup' {
        Safe-It 'calls cleanup script' {
            InModuleScope ConfigManagementTools {
                Mock Invoke-ScriptFile {} -ModuleName ConfigManagementTools
                Invoke-GroupMembershipCleanup -CsvPath 'c.csv' -GroupName 'g1'
                Assert-MockCalled Invoke-ScriptFile -ModuleName ConfigManagementTools -Times 1 -ParameterFilter { $Name -eq 'CleanupGroupMembership.ps1' }
            }
        }
        Safe-It 'throws on failure' {
            InModuleScope ConfigManagementTools {
                Mock Invoke-ScriptFile { throw 'oops' } -ModuleName ConfigManagementTools
                { Invoke-GroupMembershipCleanup -CsvPath 'c.csv' -GroupName 'g1' } | Should -Throw
            }
        }
    }

    Context 'Set-SharedMailboxAutoReply' {
        $commonParams = @{ MailboxIdentity = 'mb'; StartTime = (Get-Date); EndTime = (Get-Date).AddHours(1); InternalMessage = 'msg'; AdminUser = 'admin' }
        Safe-It 'returns simulation object' {
            InModuleScope ConfigManagementTools {
                Mock Write-STStatus {}
                $res = Set-SharedMailboxAutoReply @commonParams -Simulate
                $res.Simulated | Should -BeTrue
            }
        }
        Safe-It 'returns error object when connection fails' {
            InModuleScope ConfigManagementTools {
                Mock Write-STStatus {}
                Mock Write-STLog {}
                Mock Send-STMetric {}
                Mock Get-InstalledModule { @{ Version = [version]'1.0' } }
                Mock Find-Module { $null }
                Mock Import-Module {}
                Mock Connect-ExchangeOnline { throw 'fail' }
                Mock Disconnect-ExchangeOnline {}
                $res = Set-SharedMailboxAutoReply @commonParams -UseWebLogin
                $res.Category | Should -Be 'Exchange'
            }
        }
        Safe-It 'returns error object when connection fails without web login' {
            InModuleScope ConfigManagementTools {
                Mock Write-STStatus {}
                Mock Write-STLog {}
                Mock Send-STMetric {}
                Mock Get-InstalledModule { @{ Version = [version]'1.0' } }
                Mock Find-Module { $null }
                Mock Import-Module {}
                Mock Connect-ExchangeOnline { throw 'fail' }
                Mock Disconnect-ExchangeOnline {}
                $res = Set-SharedMailboxAutoReply @commonParams
                $res.Category | Should -Be 'Exchange'
            }
        }
    }

    Context 'Invoke-ExchangeCalendarManager' {
        Safe-It 'returns simulation object' {
            InModuleScope ConfigManagementTools {
                Mock Write-STStatus {}
                $res = Invoke-ExchangeCalendarManager -Simulate
                $res.Simulated | Should -BeTrue
            }
        }
        Safe-It 'returns error object when connect fails' {
            InModuleScope ConfigManagementTools {
                Mock Write-STStatus {}
                Mock Write-STLog {}
                Mock Send-STMetric {}
                Mock Get-InstalledModule { @{ Version = [version]'1.0' } }
                Mock Find-Module { $null }
                Mock Import-Module {}
                Mock Connect-ExchangeOnline { throw 'fail' }
                Mock Disconnect-ExchangeOnline {}
                Mock Read-Host { 'Q' }
                $res = Invoke-ExchangeCalendarManager -Action Get -DisplayName 'n' -Type Building
                $res.Category | Should -Be 'Exchange'
            }
        }
        Safe-It 'returns error object when connect fails without parameters' {
            InModuleScope ConfigManagementTools {
                Mock Write-STStatus {}
                Mock Write-STLog {}
                Mock Send-STMetric {}
                Mock Get-InstalledModule { @{ Version = [version]'1.0' } }
                Mock Find-Module { $null }
                Mock Import-Module {}
                Mock Connect-ExchangeOnline { throw 'fail' }
                Mock Disconnect-ExchangeOnline {}
                Mock Read-Host { 'Q' }
                $res = Invoke-ExchangeCalendarManager
                $res.Category | Should -Be 'Exchange'
            }
        }
    }
}
