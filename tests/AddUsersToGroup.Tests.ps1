Describe 'AddUsersToGroup Script' {
    BeforeAll {
        function Install-Module {}
        function Import-Module {}
        function Connect-MgGraph {}
        function Disconnect-MgGraph {}
        function Get-MgContext {}
        function New-MgGroupMember {}
        function Get-Group { param([string]$GroupName) }
        function Get-GroupExistingMembers { param($Group) }
        function Get-CSVFilePath {}
        function Import-Csv { param([string]$Path) }
        function Get-UserID { param([string]$UserPrincipalName) }

        function Start-Main {
            param([string]$CsvPath, [string]$GroupName)
            Connect-MgGraph
            $group = Get-Group -GroupName $GroupName
            $existing = Get-GroupExistingMembers -Group $group
            $users = (Import-Csv $CsvPath).UPN
            foreach ($u in $users) {
                if ($existing -notcontains $u) {
                    $userInfo = Get-UserID -UserPrincipalName $u
                    if ($userInfo) { New-MgGroupMember }
                }
            }
            Disconnect-MgGraph
        }
    }
    BeforeEach {
        Mock Connect-MgGraph {}
        Mock Disconnect-MgGraph {}
        Mock Get-MgContext { @{ Account = 'test' } }
        Mock Get-Group { [pscustomobject]@{ Id='1'; DisplayName='Group' } }
        Mock Get-GroupExistingMembers { @('existing@contoso.com') }
        Mock Get-CSVFilePath { 'dummy.csv' }
        Mock Import-Csv { @([pscustomobject]@{ UPN='user1@contoso.com' }, [pscustomobject]@{ UPN='existing@contoso.com' }) }
        Mock Get-UserID { param($UserPrincipalName) [pscustomobject]@{ UserPrincipalName=$UserPrincipalName; DisplayName='User'; Id='id' } }
        Mock New-MgGroupMember {}
    }
    It 'connects and disconnects from Graph' {
        Start-Main -CsvPath 'dummy.csv' -GroupName 'Group' | Out-Null
        Assert-MockCalled Connect-MgGraph -Times 1
        Assert-MockCalled Disconnect-MgGraph -Times 1
    }
    It 'imports the CSV' {
        Start-Main -CsvPath 'dummy.csv' -GroupName 'Group' | Out-Null
        Assert-MockCalled Import-Csv -ParameterFilter { $Path -eq 'dummy.csv' } -Times 1
    }
    It 'adds only missing users' {
        Start-Main -CsvPath 'dummy.csv' -GroupName 'Group' | Out-Null
        Assert-MockCalled New-MgGroupMember -Times 1
    }
}
