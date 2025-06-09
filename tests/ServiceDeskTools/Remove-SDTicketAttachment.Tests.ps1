. $PSScriptRoot/../TestHelpers.ps1

Describe 'Remove-SDTicketAttachment' {
    BeforeAll {
        Import-Module $PSScriptRoot/../../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../../src/ServiceDeskTools/ServiceDeskTools.psd1 -Force
    }

    Safe-It 'returns API response on success' {
        InModuleScope ServiceDeskTools {
            Mock Invoke-SDRequest { @{ ok = $true } }
            $res = Remove-SDTicketAttachment -Id 7
            Assert-MockCalled Invoke-SDRequest -Times 1 -ParameterFilter {
                $Method -eq 'DELETE' -and $Path -eq '/attachments/7.json'
            }
            $res.ok | Should -Be $true
        }
    }

    Safe-It 'throws when Invoke-SDRequest fails' {
        InModuleScope ServiceDeskTools {
            Mock Invoke-SDRequest { throw 'bad' }
            { Remove-SDTicketAttachment -Id 2 } | Should -Throw
        }
    }
}
