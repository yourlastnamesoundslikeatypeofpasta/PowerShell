. $PSScriptRoot/../TestHelpers.ps1

Describe 'Get-SDUser' {
    BeforeAll {
        Import-Module $PSScriptRoot/../../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../../src/ServiceDeskTools/ServiceDeskTools.psd1 -Force
    }

    Safe-It 'requests user by id' {
        InModuleScope ServiceDeskTools {
            Mock Invoke-SDRequest { @{ id = 1 } }
            $res = Get-SDUser -Id 1
            Assert-MockCalled Invoke-SDRequest -Times 1 -ParameterFilter { $Method -eq 'GET' -and $Path -eq '/users/1.json' }
            $res.id | Should -Be 1
        }
    }

    Safe-It 'requests user by email' {
        InModuleScope ServiceDeskTools {
            Mock Invoke-SDRequest { @{ email = 'a@b.com' } }
            $res = Get-SDUser -Email 'a@b.com'
            Assert-MockCalled Invoke-SDRequest -Times 1 -ParameterFilter { $Method -eq 'GET' -and $Path -eq '/users.json?email=a%40b.com' }
            $res.email | Should -Be 'a@b.com'
        }
    }

    Safe-It 'passes ChaosMode' {
        InModuleScope ServiceDeskTools {
            Mock Invoke-SDRequest { @{ ok = $true } }
            Get-SDUser -Id 2 -ChaosMode
            Assert-MockCalled Invoke-SDRequest -Times 1 -ParameterFilter { $ChaosMode -eq $true }
        }
    }

    Safe-It 'throws when Invoke-SDRequest fails' {
        InModuleScope ServiceDeskTools {
            Mock Invoke-SDRequest { throw 'bad' }
            { Get-SDUser -Id 1 } | Should -Throw
        }
    }
}
