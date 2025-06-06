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
            Assert-MockCalled Invoke-SDRequest -ModuleName ServiceDeskTools -ParameterFilter {
                $Method -eq 'POST' -and
                $Path -eq '/incidents.json' -and
                $Body.incident.name -eq 'S' -and
                $Body.incident.description -eq 'D' -and
                $Body.incident.requester_email -eq 'a@b.com'
            } -Times 1
        }
        It 'Set-SDTicket calls Invoke-SDRequest' {
            Mock Invoke-SDRequest {} -ModuleName ServiceDeskTools
            Set-SDTicket -Id 2 -Fields @{status='Open'}
            Assert-MockCalled Invoke-SDRequest -ModuleName ServiceDeskTools -ParameterFilter {
                $Method -eq 'PUT' -and
                $Path -eq '/incidents/2.json' -and
                $Body.incident.status -eq 'Open'
            } -Times 1
        }
    }

    Context 'Logging' {
        It 'Get-SDTicket logs the request' {
            Mock Invoke-SDRequest {} -ModuleName ServiceDeskTools
            Mock Write-STLog {} -ModuleName ServiceDeskTools
            Get-SDTicket -Id 5
            Assert-MockCalled Write-STLog -ModuleName ServiceDeskTools -ParameterFilter { $Message -eq 'Get-SDTicket 5' } -Times 1
        }
        It 'New-SDTicket logs the request' {
            Mock Invoke-SDRequest {} -ModuleName ServiceDeskTools
            Mock Write-STLog {} -ModuleName ServiceDeskTools
            New-SDTicket -Subject 'S' -Description 'D' -RequesterEmail 'a@b.com'
            Assert-MockCalled Write-STLog -ModuleName ServiceDeskTools -ParameterFilter { $Message -eq 'New-SDTicket S' } -Times 1
        }
        It 'Set-SDTicket logs the request' {
            Mock Invoke-SDRequest {} -ModuleName ServiceDeskTools
            Mock Write-STLog {} -ModuleName ServiceDeskTools
            Set-SDTicket -Id 3 -Fields @{status='Closed'}
            Assert-MockCalled Write-STLog -ModuleName ServiceDeskTools -ParameterFilter { $Message -eq 'Set-SDTicket 3' } -Times 1
        }
    }

    Context 'Invoke-SDRequest behavior' {
        It 'throws when SD_API_TOKEN is missing' {
            InModuleScope ServiceDeskTools {
                Remove-Item env:SD_API_TOKEN -ErrorAction SilentlyContinue
                { Invoke-SDRequest -Method 'GET' -Path '/incidents/1.json' } | Should -Throw
            }
        }
        It 'uses default base URI when SD_BASE_URI not set' {
            InModuleScope ServiceDeskTools {
                $env:SD_API_TOKEN = 't'
                Remove-Item env:SD_BASE_URI -ErrorAction SilentlyContinue
                Mock Write-STLog {} -ModuleName ServiceDeskTools
                Mock Invoke-RestMethod {} -ModuleName ServiceDeskTools
                Invoke-SDRequest -Method 'GET' -Path '/incidents/1.json'
                Assert-MockCalled Invoke-RestMethod -ModuleName ServiceDeskTools -ParameterFilter { $Uri -eq 'https://api.samanage.com/incidents/1.json' } -Times 1
                Remove-Item env:SD_API_TOKEN
            }
        }
        It 'uses SD_BASE_URI when set' {
            InModuleScope ServiceDeskTools {
                $env:SD_API_TOKEN = 't'
                $env:SD_BASE_URI = 'https://custom.example.com/api/'
                Mock Write-STLog {} -ModuleName ServiceDeskTools
                Mock Invoke-RestMethod {} -ModuleName ServiceDeskTools
                Invoke-SDRequest -Method 'GET' -Path '/incidents/2.json'
                Assert-MockCalled Invoke-RestMethod -ModuleName ServiceDeskTools -ParameterFilter { $Uri -eq 'https://custom.example.com/api/incidents/2.json' } -Times 1
                Remove-Item env:SD_API_TOKEN
                Remove-Item env:SD_BASE_URI
            }
        }
        It 'converts body to JSON' {
            InModuleScope ServiceDeskTools {
                $env:SD_API_TOKEN = 't'
                Mock Write-STLog {} -ModuleName ServiceDeskTools
                Mock Invoke-RestMethod {} -ModuleName ServiceDeskTools
                $body = @{ value = 1 }
                $expected = $body | ConvertTo-Json -Depth 10
                Invoke-SDRequest -Method 'POST' -Path '/test' -Body $body
                Assert-MockCalled Invoke-RestMethod -ModuleName ServiceDeskTools -ParameterFilter {
                    $Body -eq $expected -and $ContentType -eq 'application/json'
                } -Times 1
                Remove-Item env:SD_API_TOKEN
            }
        }
    }
}
