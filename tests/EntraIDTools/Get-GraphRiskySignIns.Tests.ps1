. $PSScriptRoot/../TestHelpers.ps1

Describe 'Get-GraphRiskySignIns function' {
    BeforeAll {
        Import-Module $PSScriptRoot/../../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../../src/Telemetry/Telemetry.psd1 -Force
        Import-Module $PSScriptRoot/../../src/EntraIDTools/EntraIDTools.psd1 -Force
        . $PSScriptRoot/../../src/EntraIDTools/Private/Get-GraphAccessToken.ps1
    }

    Safe-It 'returns risk events from Graph' {
        $expected = @(
            [pscustomobject]@{ id = '1'; userPrincipalName = 'user@test'; riskLevel = 'high' }
        )
        Mock Get-GraphAccessToken { 'tok' } -ModuleName EntraIDTools
        Mock Invoke-STRequest { @{ value = $expected } } -ModuleName EntraIDTools -ParameterFilter { $Method -eq 'GET' }
        Mock Write-STTelemetryEvent {} -ModuleName EntraIDTools

        $result = Get-GraphRiskySignIns -TenantId 'tid' -ClientId 'cid'
        $result | Should -Be $expected
    }

    Safe-It 'logs errors when Graph call fails' {
        Mock Get-GraphAccessToken { 'tok' } -ModuleName EntraIDTools
        Mock Invoke-STRequest { throw 'bad' } -ModuleName EntraIDTools -ParameterFilter { $Method -eq 'GET' }
        Mock Write-STLog {} -ModuleName EntraIDTools
        Mock Write-STTelemetryEvent {} -ModuleName EntraIDTools

        { Get-GraphRiskySignIns -TenantId 'tid' -ClientId 'cid' } | Should -Throw
        Assert-MockCalled Write-STLog -ModuleName EntraIDTools -Times 1 -ParameterFilter { $Level -eq 'ERROR' }
    }
}
