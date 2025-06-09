. $PSScriptRoot/../TestHelpers.ps1

Describe 'Get-GraphSignInLogs request' {
    BeforeAll {
        Import-Module $PSScriptRoot/../../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../../src/Telemetry/Telemetry.psd1 -Force
        Import-Module $PSScriptRoot/../../src/EntraIDTools/EntraIDTools.psd1 -Force
        . $PSScriptRoot/../../src/EntraIDTools/Private/Get-GraphAccessToken.ps1
    }

    Safe-It 'targets auditLogs/signIns and records telemetry' {
        Mock Get-GraphAccessToken { 'token' } -ModuleName EntraIDTools
        Mock Invoke-STRequest { @{ value=@() } } -ModuleName EntraIDTools -ParameterFilter { $Method -eq 'GET' }
        Mock Write-STTelemetryEvent {} -ModuleName EntraIDTools

        Get-GraphSignInLogs -TenantId 'tid' -ClientId 'cid'

        Assert-MockCalled Invoke-STRequest -ModuleName EntraIDTools -Times 1 -ParameterFilter { $Uri -match '/auditLogs/signIns' }
        Assert-MockCalled Write-STTelemetryEvent -ModuleName EntraIDTools -Times 1
    }
}
