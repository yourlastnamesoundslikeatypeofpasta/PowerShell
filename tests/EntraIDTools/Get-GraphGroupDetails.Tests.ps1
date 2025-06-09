. $PSScriptRoot/../TestHelpers.ps1

Describe 'Get-GraphGroupDetails outputs' {
    BeforeAll {
        Import-Module $PSScriptRoot/../../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../../src/Telemetry/Telemetry.psd1 -Force
        Import-Module $PSScriptRoot/../../src/EntraIDTools/EntraIDTools.psd1 -Force
        . $PSScriptRoot/../../src/EntraIDTools/Private/Get-GraphAccessToken.ps1
    }

    It 'returns expected properties from Graph' {
        Mock Get-GraphAccessToken { 't' } -ModuleName EntraIDTools
        Mock Invoke-STRequest -ModuleName EntraIDTools -ParameterFilter { $Method -eq 'GET' } {
            switch -regex ($Uri) {
                'groups/.+\?$' { @{ displayName = 'GroupName'; description = 'GroupDesc' } }
                'members' { @{ value = @(@{ displayName = 'UserA' }, @{ displayName = 'UserB' }) } }
            }
        }

        $res = Get-GraphGroupDetails -GroupId 'gid' -TenantId 'tid' -ClientId 'cid'
        $res.GroupId     | Should -Be 'gid'
        $res.DisplayName | Should -Be 'GroupName'
        $res.Description | Should -Be 'GroupDesc'
        $res.Members     | Should -Be 'UserA,UserB'
    }

    It 'returns expected properties from AD' {
        Mock Get-ADGroup { @{ Name = 'GroupName'; Description = 'GroupDesc' } } -ModuleName EntraIDTools
        Mock Get-ADGroupMember { @([pscustomobject]@{ SamAccountName = 'UserA' }, [pscustomobject]@{ SamAccountName = 'UserB' }) } -ModuleName EntraIDTools
        Mock Get-ADUser { param($InputObject) [pscustomobject]@{ Name = $InputObject.SamAccountName } } -ModuleName EntraIDTools
        $res = Get-GraphGroupDetails -GroupId 'gid' -TenantId 'tid' -ClientId 'cid' -Cloud 'AD'
        $res.GroupId     | Should -Be 'gid'
        $res.DisplayName | Should -Be 'GroupName'
        $res.Description | Should -Be 'GroupDesc'
        $res.Members     | Should -Be 'UserA,UserB'
    }
}
