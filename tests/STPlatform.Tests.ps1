Describe 'STPlatform Module' {
    BeforeAll {
        Import-Module $PSScriptRoot/../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../src/Telemetry/Telemetry.psd1 -Force
        Import-Module $PSScriptRoot/../src/STPlatform/STPlatform.psd1 -Force
    }

    It 'exports Connect-STPlatform' {
        (Get-Command -Module STPlatform).Name | Should -Contain 'Connect-STPlatform'
    }

    It 'includes Vault parameter' {
        (Get-Command Connect-STPlatform).Parameters.Keys | Should -Contain 'Vault'
    }

    It 'loads secrets when variables missing' {
        InModuleScope STPlatform {
            Remove-Item env:SPTOOLS_CLIENT_ID -ErrorAction SilentlyContinue
            Mock Get-Secret { 'fromvault' }
            Connect-STPlatform -Mode Cloud -Vault 'Test'
            Assert-MockCalled Get-Secret -ParameterFilter { $Name -eq 'SPTOOLS_CLIENT_ID' -and $Vault -eq 'Test' } -Times 1
            $env:SPTOOLS_CLIENT_ID | Should -Be 'fromvault'
            Remove-Item env:SPTOOLS_CLIENT_ID -ErrorAction SilentlyContinue
        }
    }
}
