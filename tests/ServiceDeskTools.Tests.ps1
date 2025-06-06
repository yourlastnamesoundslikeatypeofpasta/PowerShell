Describe 'ServiceDeskTools Module' {
    BeforeAll {
        Import-Module $PSScriptRoot/../src/ServiceDeskTools/ServiceDeskTools.psd1 -Force
    }

    Context 'Exported commands' {
        $expected = @('Get-SDTicket','New-SDTicket','Set-SDTicket')
        $exported = (Get-Command -Module ServiceDeskTools).Name
        foreach ($cmd in $expected) {
            It "Exports $cmd" {
                $exported | Should -Contain $cmd
            }
        }
    }

    Context 'Request routing' {
        It 'Get-SDTicket calls Invoke-SDRequest' {
            Mock Invoke-SDRequest {} -ModuleName ServiceDeskTools
            Get-SDTicket -Id 1
            Assert-MockCalled Invoke-SDRequest -ModuleName ServiceDeskTools -ParameterFilter { $Method -eq 'GET' -and $Path -eq '/incidents/1.json' } -Times 1
        }
        It 'New-SDTicket calls Invoke-SDRequest' {
            Mock Invoke-SDRequest {} -ModuleName ServiceDeskTools
            New-SDTicket -Subject 'S' -Description 'D' -RequesterEmail 'a@b.com'
            Assert-MockCalled Invoke-SDRequest -ModuleName ServiceDeskTools -ParameterFilter { $Method -eq 'POST' -and $Path -eq '/incidents.json' } -Times 1
        }
        It 'Set-SDTicket calls Invoke-SDRequest' {
            Mock Invoke-SDRequest {} -ModuleName ServiceDeskTools
            Set-SDTicket -Id 2 -Fields @{status='Open'}
            Assert-MockCalled Invoke-SDRequest -ModuleName ServiceDeskTools -ParameterFilter { $Method -eq 'PUT' -and $Path -eq '/incidents/2.json' } -Times 1
        }
    }
}
