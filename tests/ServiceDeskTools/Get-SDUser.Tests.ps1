. $PSScriptRoot/../TestHelpers.ps1

Describe 'Get-SDUser' {
    Initialize-TestDrive
    BeforeAll {
        Import-Module $PSScriptRoot/../../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../../src/ServiceDeskTools/ServiceDeskTools.psd1 -Force
    }

    Safe-It 'returns API response on success' {
        InModuleScope ServiceDeskTools {
            Mock Invoke-SDRequest { @{ ok = $true } }
            $res = Get-SDUser -Id 1
            Assert-MockCalled Invoke-SDRequest -Times 1 -ParameterFilter {
                $Method -eq 'GET' -and $Path -eq '/users/1.json'
            }
            $res.ok | Should -Be $true
        }
    }

    Safe-It 'throws when Invoke-SDRequest fails' {
        InModuleScope ServiceDeskTools {
            Mock Invoke-SDRequest { throw 'bad' }
            { Get-SDUser -Id 2 } | Should -Throw
        }
    }
}
