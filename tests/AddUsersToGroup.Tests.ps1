Describe 'AddUsersToGroup Script' {
    BeforeAll {
        $scriptPath = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath 'scripts/AddUsersToGroup.ps1'
        function Install-Module {}
        function Import-Module {}
        function Connect-MgGraph {}
        function Disconnect-MgGraph {}
        function Get-MgContext {}
        function New-MgGroupMember {}
        Mock Add-Type {}
        Mock Import-Module {}
        Mock Install-Module {}
        Mock Start-Main {}
        . $scriptPath -CsvPath 'dummy.csv' -GroupName 'Group'
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
