. $PSScriptRoot/../TestHelpers.ps1

Describe 'Get-ServiceDeskStats' {
    BeforeAll {
        Import-Module $PSScriptRoot/../../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../../src/Telemetry/Telemetry.psd1 -Force
        Import-Module $PSScriptRoot/../../src/ServiceDeskTools/ServiceDeskTools.psd1 -Force
    }

    Safe-It 'groups incidents by status' {
        InModuleScope ServiceDeskTools {
            $data = @(
                @{ state = 'Open' },
                @{ state = 'Resolved' },
                @{ state = 'Open' }
            )
            Mock Invoke-SDRequest { $data }
            $stats = Get-ServiceDeskStats -StartDate (Get-Date).AddDays(-1) -EndDate (Get-Date)
            Assert-MockCalled Invoke-SDRequest -Times 1 -ParameterFilter { $Method -eq 'GET' -and $Path -match '/incidents.json' }
            $stats.Open | Should -Be 2
            $stats.Resolved | Should -Be 1
        }
    }

    Safe-It 'throws when Invoke-SDRequest fails' {
        InModuleScope ServiceDeskTools {
            Mock Invoke-SDRequest { throw 'bad' }
            { Get-ServiceDeskStats -StartDate (Get-Date) -EndDate (Get-Date) } | Should -Throw
        }
    }
}
