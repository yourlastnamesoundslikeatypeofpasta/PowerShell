. $PSScriptRoot/../TestHelpers.ps1

Describe 'Get-UserInfoHybrid results' {
    Initialize-TestDrive
    BeforeAll {
        Import-Module $PSScriptRoot/../../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../../src/Telemetry/Telemetry.psd1 -Force
        Import-Module $PSScriptRoot/../../src/EntraIDTools/EntraIDTools.psd1 -Force
        . $PSScriptRoot/../../src/EntraIDTools/Private/Get-GraphAccessToken.ps1
    }

    It 'merges Graph and AD attributes' {
        Mock Get-GraphAccessToken { 't' } -ModuleName EntraIDTools
        Mock Invoke-STRequest -ModuleName EntraIDTools -ParameterFilter { $Method -eq 'GET' } {
            switch -regex ($Uri) {
                'v1\.0/users/.+\?' { @{ id='1'; displayName='Graph User'; userPrincipalName='u@test' } }
                'licenseDetails'    { @{ value=@(@{ skuPartNumber='A1' }) } }
                'memberOf'          { @{ value=@(@{ displayName='Group1' }) } }
                'beta/users/.+'     { @{ signInActivity = @{ lastSignInDateTime='2024-01-01T00:00:00Z' } } }
            }
        }
        Mock Get-ADUser { [pscustomobject]@{ SamAccountName='sam'; Enabled=$true; LastLogonDate='2024-02-01' } } -ModuleName EntraIDTools

        $res = Get-UserInfoHybrid -UserPrincipalName 'u@test' -TenantId 'tid' -ClientId 'cid'
        $res.DisplayName    | Should -Be 'Graph User'
        $res.SamAccountName | Should -Be 'sam'
        $res.Enabled        | Should -Be $true
        $res.LastSignIn     | Should -Be '2024-01-01T00:00:00Z'
    }
}
