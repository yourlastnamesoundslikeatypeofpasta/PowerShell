. $PSScriptRoot/../TestHelpers.ps1

Describe 'Add-SDTicketComment' {
    Initialize-TestDrive
    BeforeAll {
        Import-Module $PSScriptRoot/../../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../../src/ServiceDeskTools/ServiceDeskTools.psd1 -Force
    }

    Safe-It 'returns API response on success' {
        InModuleScope ServiceDeskTools {
            Mock Invoke-SDRequest { @{ ok = $true } }
            $res = Add-SDTicketComment -Id 1 -Comment 'done'
            Assert-MockCalled Invoke-SDRequest -Times 1 -ParameterFilter {
                $Method -eq 'POST' -and
                $Path -eq '/incidents/1/comments.json' -and
                $Body.comment.body -eq 'done'
            }
            $res.ok | Should -Be $true
        }
    }

    Safe-It 'throws when Invoke-SDRequest fails' {
        InModuleScope ServiceDeskTools {
            Mock Invoke-SDRequest { throw 'bad' }
            { Add-SDTicketComment -Id 2 -Comment 'x' } | Should -Throw
        }
    }
}
