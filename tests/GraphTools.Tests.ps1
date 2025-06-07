Describe 'GraphTools Module' {
    BeforeAll {
        Import-Module $PSScriptRoot/../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../src/Telemetry/Telemetry.psd1 -Force
        Import-Module $PSScriptRoot/../src/GraphTools/GraphTools.psd1 -Force
    }

    Context 'Exported commands' {
        It 'Exports Get-GraphUserDetails' {
            (Get-Command -Module GraphTools).Name | Should -Contain 'Get-GraphUserDetails'
        }
    }

    Context 'Logging and telemetry' {
        It 'Logs requests and writes telemetry' {
            Mock Get-GraphAccessToken { 't' } -ModuleName GraphTools
            Mock Invoke-RestMethod { @{ id='1'; displayName='User'; userPrincipalName='u' } } -ModuleName GraphTools -ParameterFilter { $Method -eq 'GET' }
            Mock Write-STLog {} -ModuleName GraphTools
            Mock Write-STTelemetryEvent {} -ModuleName GraphTools
            Get-GraphUserDetails -UserPrincipalName 'u' -TenantId 'tid' -ClientId 'cid'
            Assert-MockCalled Write-STLog -ModuleName GraphTools -Times 1
            Assert-MockCalled Write-STTelemetryEvent -ModuleName GraphTools -Times 1
        }
    }
}
