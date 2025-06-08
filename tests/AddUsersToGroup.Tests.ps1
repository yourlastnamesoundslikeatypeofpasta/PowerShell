Describe 'AddUsersToGroup Script' {
    BeforeAll {
        function Install-Module {}
        function Import-Module {}
        function Connect-MgGraph {}
        function Disconnect-MgGraph {}
        function Get-MgContext {}
        function New-MgGroupMember {}
        function Add-ADGroupMember {}
        function Get-ADGroup {}
        function Get-ADGroupMember {}
        function Get-ADUser {}
        function Get-Group { param([string]$GroupName) }
        function Get-GroupExistingMembers { param($Group) }
        function Get-CSVFilePath {}
        function Import-Csv { param([string]$Path) }
        function Get-UserID { param([string]$UserPrincipalName) }
        function Write-STStatus { param([string]$Message, [string]$Level) }
        # Stub Add-Type so the script can be dot-sourced without loading GUI assemblies
        function Add-Type {}
        . $PSScriptRoot/../scripts/AddUsersToGroup.ps1
        Remove-Item function:Add-Type -ErrorAction SilentlyContinue
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
        Mock Add-ADGroupMember {}
        Mock Get-ADGroup {}
        Mock Get-ADGroupMember {}
        Mock Get-ADUser {}
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

    It 'uses AD cmdlets when Cloud is AD' {
        Start-Main -CsvPath 'dummy.csv' -GroupName 'Group' -Cloud 'AD' | Out-Null
        Assert-MockCalled Add-ADGroupMember -Times 1
        Assert-MockCalled Connect-MgGraph -Times 0
    }
}
