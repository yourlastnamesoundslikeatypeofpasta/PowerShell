. $PSScriptRoot/../TestHelpers.ps1

Describe 'Disable-GraphUser' {
    Initialize-TestDrive
    BeforeAll {
        Import-Module $PSScriptRoot/../../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../../src/Telemetry/Telemetry.psd1 -Force
        Import-Module $PSScriptRoot/../../src/EntraIDTools/EntraIDTools.psd1 -Force
        . $PSScriptRoot/../../src/EntraIDTools/Private/Get-GraphAccessToken.ps1
    }

    It 'sends PATCH /users/<id> with accountEnabled=false' {
        Mock Get-GraphAccessToken { 'token' } -ModuleName EntraIDTools
        Mock Invoke-STRequest {} -ModuleName EntraIDTools

        Disable-GraphUser -UserPrincipalName 'user@test' -TenantId 'tid' -ClientId 'cid' -ClientSecret 'sec'

        Assert-MockCalled Invoke-STRequest -ModuleName EntraIDTools -Times 1 -ParameterFilter {
            $Method -eq 'PATCH' -and
            $Uri -eq 'https://graph.microsoft.com/v1.0/users/user@test' -and
            $Body.accountEnabled -eq $false
        }
    }
}
