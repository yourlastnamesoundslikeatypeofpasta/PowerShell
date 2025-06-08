Describe 'Add-UserToGroup function' {
    BeforeAll {
        Import-Module $PSScriptRoot/../../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../../src/SupportTools/SupportTools.psd1 -Force
    }

    BeforeEach {
        InModuleScope SupportTools {
            Mock Connect-MgGraph {}
            Mock Get-MgContext { [pscustomobject]@{ Account='acc' } }
            Mock Disconnect-MgGraph {}
            Mock Get-MgGroup { [pscustomobject]@{ Id='grp'; DisplayName='Group' } }
            Mock Get-MgGroupMember { [pscustomobject]@{ Id=@('user1') } }
            Mock Get-MgUser {
                param($UserId)
                [pscustomobject]@{ Id=$UserId; UserPrincipalName=$UserId; DisplayName=$UserId }
            }
            Mock Import-Csv {
                [pscustomobject]@{ UPN='user1' },
                [pscustomobject]@{ UPN='user2' }
            }
            Mock New-MgGroupMember {}
        }
    }

    It 'adds only new users to the group' {
        InModuleScope SupportTools {
            $result = Add-UserToGroup -CsvPath 'users.csv' -GroupName 'Group'
            Assert-MockCalled New-MgGroupMember -Times 1 -ParameterFilter { $DirectoryObjectId -eq 'user2' }
            $result.GroupName    | Should -Be 'Group'
            $result.AddedUsers   | Should -Be @('user2')
            $result.SkippedUsers | Should -Be @('user1')
        }
    }

    It 'accepts pipeline input' {
        InModuleScope SupportTools {
            [pscustomobject]@{ CsvPath='users.csv'; GroupName='Group' } | Add-UserToGroup
            Assert-MockCalled Connect-MgGraph -Times 1
        }
    }
}
