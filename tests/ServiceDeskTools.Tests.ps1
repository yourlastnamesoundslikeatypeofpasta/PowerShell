. $PSScriptRoot/TestHelpers.ps1
Describe 'ServiceDeskTools Module' {
    BeforeAll {
        Import-Module $PSScriptRoot/../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../src/ServiceDeskTools/ServiceDeskTools.psd1 -Force
    }

    Context 'Exported commands' {
        $expected = @(
            'Get-SDTicket','Get-SDTicketHistory','New-SDTicket','Set-SDTicket',
            'Add-SDTicketComment','Search-SDTicket','Get-ServiceDeskAsset',
            'Set-SDTicketBulk','Link-SDTicketToSPTask'
        )
        $exported = (Get-Command -Module ServiceDeskTools).Name
        foreach ($cmd in $expected) {
            Safe-It "Exports $cmd" {
                $exported | Should -Contain $cmd
            }
        }
    }

    Context 'Request routing' {
        Safe-It 'Get-SDTicket calls Invoke-SDRequest' {
            Mock Invoke-SDRequest {} -ModuleName ServiceDeskTools
            Get-SDTicket -Id 1
            Assert-MockCalled Invoke-SDRequest -ModuleName ServiceDeskTools -ParameterFilter { $Method -eq 'GET' -and $Path -eq '/incidents/1.json' } -Times 1
        }
        Safe-It 'Get-SDTicketHistory calls Invoke-SDRequest' {
            Mock Invoke-SDRequest {} -ModuleName ServiceDeskTools
            Get-SDTicketHistory -Id 1
            Assert-MockCalled Invoke-SDRequest -ModuleName ServiceDeskTools -ParameterFilter { $Method -eq 'GET' -and $Path -eq '/incidents/1/audits.json' } -Times 1
        }
        Safe-It 'Get-SDTicketHistory passes ChaosMode' {
            Mock Invoke-SDRequest {} -ModuleName ServiceDeskTools
            Get-SDTicketHistory -Id 1 -ChaosMode
            Assert-MockCalled Invoke-SDRequest -ModuleName ServiceDeskTools -ParameterFilter {
                $ChaosMode -eq $true -and $Method -eq 'GET' -and $Path -eq '/incidents/1/audits.json'
            } -Times 1
        }
        Safe-It 'New-SDTicket calls Invoke-SDRequest' {
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
        Safe-It 'Set-SDTicket calls Invoke-SDRequest' {
            Mock Invoke-SDRequest {} -ModuleName ServiceDeskTools
            Set-SDTicket -Id 2 -Fields @{status='Open'}
            Assert-MockCalled Invoke-SDRequest -ModuleName ServiceDeskTools -ParameterFilter {
                $Method -eq 'PUT' -and
                $Path -eq '/incidents/2.json' -and
                $Body.incident.status -eq 'Open'
            } -Times 1
        }
        Safe-It 'Add-SDTicketComment calls Invoke-SDRequest' {
            Mock Invoke-SDRequest {} -ModuleName ServiceDeskTools
            Add-SDTicketComment -Id 5 -Comment 'c'
            Assert-MockCalled Invoke-SDRequest -ModuleName ServiceDeskTools -ParameterFilter {
                $Method -eq 'POST' -and
                $Path -eq '/incidents/5/comments.json' -and
                $Body.comment.body -eq 'c'
            } -Times 1
        }
        Safe-It 'Add-SDTicketComment passes ChaosMode' {
            Mock Invoke-SDRequest {} -ModuleName ServiceDeskTools
            Add-SDTicketComment -Id 5 -Comment 'c' -ChaosMode
            Assert-MockCalled Invoke-SDRequest -ModuleName ServiceDeskTools -ParameterFilter {
                $ChaosMode -eq $true -and
                $Method -eq 'POST' -and
                $Path -eq '/incidents/5/comments.json'
            } -Times 1
        }
        Safe-It 'Search-SDTicket calls Invoke-SDRequest' {
            Mock Invoke-SDRequest {} -ModuleName ServiceDeskTools
            Search-SDTicket -Query 'error'
            Assert-MockCalled Invoke-SDRequest -ModuleName ServiceDeskTools -ParameterFilter {
                $Method -eq 'GET' -and $Path -eq '/incidents.json?search=error'
            } -Times 1
        }
        Safe-It 'Get-ServiceDeskAsset calls Invoke-SDRequest' {
            Mock Invoke-SDRequest {} -ModuleName ServiceDeskTools
            Get-ServiceDeskAsset -Id 4
            Assert-MockCalled Invoke-SDRequest -ModuleName ServiceDeskTools -ParameterFilter {
                $Method -eq 'GET' -and $Path -eq '/assets/4.json'
            } -Times 1
        }
        Safe-It 'Get-ServiceDeskAsset passes ChaosMode' {
            Mock Invoke-SDRequest {} -ModuleName ServiceDeskTools
            Get-ServiceDeskAsset -Id 4 -ChaosMode
            Assert-MockCalled Invoke-SDRequest -ModuleName ServiceDeskTools -ParameterFilter {
                $ChaosMode -eq $true -and $Method -eq 'GET' -and $Path -eq '/assets/4.json'
            } -Times 1
        }
        Safe-It 'Set-SDTicketBulk calls Set-SDTicket for each id' {
            Mock Set-SDTicket {} -ModuleName ServiceDeskTools
            Set-SDTicketBulk -Id 10,11 -Fields @{status='Closed'}
            Assert-MockCalled Set-SDTicket -ModuleName ServiceDeskTools -ParameterFilter { $Id -eq 10 } -Times 1
            Assert-MockCalled Set-SDTicket -ModuleName ServiceDeskTools -ParameterFilter { $Id -eq 11 } -Times 1
        }
        Safe-It 'Link-SDTicketToSPTask calls Set-SDTicket' {
            Mock Set-SDTicket {} -ModuleName ServiceDeskTools
            Link-SDTicketToSPTask -TicketId 12 -TaskUrl 'https://contoso/tasks/1'
            Assert-MockCalled Set-SDTicket -ModuleName ServiceDeskTools -ParameterFilter {
                $Id -eq 12 -and $Fields.sharepoint_task_url -eq 'https://contoso/tasks/1'
            } -Times 1
        }
    }

    Context 'Logging' {
        Safe-It 'Get-SDTicket logs the request' {
            Mock Invoke-SDRequest {} -ModuleName ServiceDeskTools
            Mock Write-STLog {} -ModuleName ServiceDeskTools
            Get-SDTicket -Id 5
            Assert-MockCalled Write-STLog -ModuleName ServiceDeskTools -ParameterFilter { $Message -eq 'Get-SDTicket 5' } -Times 1
        }
        Safe-It 'New-SDTicket logs the request' {
            Mock Invoke-SDRequest {} -ModuleName ServiceDeskTools
            Mock Write-STLog {} -ModuleName ServiceDeskTools
            New-SDTicket -Subject 'S' -Description 'D' -RequesterEmail 'a@b.com'
            Assert-MockCalled Write-STLog -ModuleName ServiceDeskTools -ParameterFilter { $Message -eq 'New-SDTicket S' } -Times 1
        }
        Safe-It 'Set-SDTicket logs the request' {
            Mock Invoke-SDRequest {} -ModuleName ServiceDeskTools
            Mock Write-STLog {} -ModuleName ServiceDeskTools
            Set-SDTicket -Id 3 -Fields @{status='Closed'}
            Assert-MockCalled Write-STLog -ModuleName ServiceDeskTools -ParameterFilter { $Message -eq 'Set-SDTicket 3' } -Times 1
        }
        Safe-It 'Search-SDTicket logs the request' {
            Mock Invoke-SDRequest {} -ModuleName ServiceDeskTools
            Mock Write-STLog {} -ModuleName ServiceDeskTools
            Search-SDTicket -Query 'fail'
            Assert-MockCalled Write-STLog -ModuleName ServiceDeskTools -ParameterFilter { $Message -eq 'Search-SDTicket fail' } -Times 1
        }
        Safe-It 'Get-ServiceDeskAsset logs the request' {
            Mock Invoke-SDRequest {} -ModuleName ServiceDeskTools
            Mock Write-STLog {} -ModuleName ServiceDeskTools
            Get-ServiceDeskAsset -Id 6
            Assert-MockCalled Write-STLog -ModuleName ServiceDeskTools -ParameterFilter { $Message -eq 'Get-ServiceDeskAsset 6' } -Times 1
        }
        Safe-It 'Set-SDTicketBulk logs each id' {
            Mock Set-SDTicket {} -ModuleName ServiceDeskTools
            Mock Write-STLog {} -ModuleName ServiceDeskTools
            Set-SDTicketBulk -Id 7,8 -Fields @{priority='High'}
            Assert-MockCalled Write-STLog -ModuleName ServiceDeskTools -ParameterFilter { $Message -eq 'Set-SDTicketBulk 7' } -Times 1
            Assert-MockCalled Write-STLog -ModuleName ServiceDeskTools -ParameterFilter { $Message -eq 'Set-SDTicketBulk 8' } -Times 1
        }
        Safe-It 'Add-SDTicketComment logs the request' {
            Mock Invoke-SDRequest {} -ModuleName ServiceDeskTools
            Mock Write-STLog {} -ModuleName ServiceDeskTools
            Add-SDTicketComment -Id 8 -Comment 'c'
            Assert-MockCalled Write-STLog -ModuleName ServiceDeskTools -ParameterFilter { $Message -eq 'Add-SDTicketComment 8' } -Times 1
        }
        Safe-It 'Link-SDTicketToSPTask logs the update' {
            Mock Set-SDTicket {} -ModuleName ServiceDeskTools
            Mock Write-STLog {} -ModuleName ServiceDeskTools
            Link-SDTicketToSPTask -TicketId 9 -TaskUrl 'https://contoso/tasks/9'
            Assert-MockCalled Write-STLog -ModuleName ServiceDeskTools -ParameterFilter { $Message -eq 'Link-SDTicketToSPTask 9 https://contoso/tasks/9' } -Times 1
        }
        Safe-It 'Submit-Ticket calls New-SDTicket and logs the action' {
            Mock New-SDTicket {} -ModuleName ServiceDeskTools
            Mock Write-STLog {} -ModuleName ServiceDeskTools
            Submit-Ticket -Subject 'S' -Description 'D' -RequesterEmail 'a@b.com'
            Assert-MockCalled New-SDTicket -ModuleName ServiceDeskTools -ParameterFilter {
                $Subject -eq 'S' -and $Description -eq 'D' -and $RequesterEmail -eq 'a@b.com'
            } -Times 1
            Assert-MockCalled Write-STLog -ModuleName ServiceDeskTools -ParameterFilter { $Message -eq 'Submit-Ticket S' } -Times 1
        }
    }

    Context 'Invoke-SDRequest behavior' {
        Safe-It 'throws when SD_API_TOKEN is missing' {
            InModuleScope ServiceDeskTools {
                Remove-Item env:SD_API_TOKEN -ErrorAction SilentlyContinue
                { Invoke-SDRequest -Method 'GET' -Path '/incidents/1.json' } | Should -Throw
            }
        }
        Safe-It 'uses default base URI when SD_BASE_URI not set' {
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
        Safe-It 'uses SD_BASE_URI when set' {
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
        Safe-It 'uses SD_BASE_URI for assets when SD_ASSET_BASE_URI not set' {
            InModuleScope ServiceDeskTools {
                $env:SD_API_TOKEN = 't'
                $env:SD_BASE_URI = 'https://custom.example.com/api/'
                Remove-Item env:SD_ASSET_BASE_URI -ErrorAction SilentlyContinue
                Mock Write-STLog {} -ModuleName ServiceDeskTools
                Mock Invoke-RestMethod {} -ModuleName ServiceDeskTools
                Get-ServiceDeskAsset -Id 3
                Assert-MockCalled Invoke-RestMethod -ModuleName ServiceDeskTools -ParameterFilter { $Uri -eq 'https://custom.example.com/api/assets/3.json' } -Times 1
                Remove-Item env:SD_API_TOKEN
                Remove-Item env:SD_BASE_URI
            }
        }
        Safe-It 'uses SD_ASSET_BASE_URI when set' {
            InModuleScope ServiceDeskTools {
                $env:SD_API_TOKEN = 't'
                $env:SD_ASSET_BASE_URI = 'https://assets.example.com/api/'
                Mock Write-STLog {} -ModuleName ServiceDeskTools
                Mock Invoke-RestMethod {} -ModuleName ServiceDeskTools
                Get-ServiceDeskAsset -Id 4
                Assert-MockCalled Invoke-RestMethod -ModuleName ServiceDeskTools -ParameterFilter { $Uri -eq 'https://assets.example.com/api/assets/4.json' } -Times 1
                Remove-Item env:SD_API_TOKEN
                Remove-Item env:SD_ASSET_BASE_URI
            }
        }
        Safe-It 'converts body to JSON' {
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

    Context 'WhatIf support' {
        Safe-It 'New-SDTicket does not invoke request when -WhatIf used' {
            Mock Invoke-SDRequest {} -ModuleName ServiceDeskTools
            New-SDTicket -Subject 's' -Description 'd' -RequesterEmail 'a@b.com' -WhatIf
            Assert-MockCalled Invoke-SDRequest -Times 0 -ModuleName ServiceDeskTools
        }
        Safe-It 'Set-SDTicket does not invoke request when -WhatIf used' {
            Mock Invoke-SDRequest {} -ModuleName ServiceDeskTools
            Set-SDTicket -Id 1 -Fields @{status='Open'} -WhatIf
            Assert-MockCalled Invoke-SDRequest -Times 0 -ModuleName ServiceDeskTools
        }
    }

    Context 'Rate limiting and chaos mode' {
        Safe-It 'pauses when SD_RATE_LIMIT_PER_MINUTE reached' {
            InModuleScope ServiceDeskTools {
                $env:SD_API_TOKEN = 't'
                $env:SD_RATE_LIMIT_PER_MINUTE = '2'
                $dates = @(
                    [datetime]'2023-01-01T00:00:00Z',
                    [datetime]'2023-01-01T00:00:30Z',
                    [datetime]'2023-01-01T00:00:40Z'
                )
                $i = 0
                Mock Get-Date { $dates[$i++] } -ModuleName ServiceDeskTools
                Mock Start-Sleep {} -ModuleName ServiceDeskTools
                Mock Invoke-RestMethod {} -ModuleName ServiceDeskTools

                Invoke-SDRequest -Method 'GET' -Path '/one'
                Invoke-SDRequest -Method 'GET' -Path '/two'
                Invoke-SDRequest -Method 'GET' -Path '/three'

                Assert-MockCalled Start-Sleep -ModuleName ServiceDeskTools -Times 1

                Remove-Item env:SD_API_TOKEN
                Remove-Item env:SD_RATE_LIMIT_PER_MINUTE
            }
        }

        Safe-It 'honors ST_CHAOS_MODE with simulated failures' {
            InModuleScope ServiceDeskTools {
                $env:SD_API_TOKEN = 't'
                $env:ST_CHAOS_MODE = '1'
                $random = @(1000, 5)
                $r = 0
                Mock Get-Random { $random[$r++] } -ModuleName ServiceDeskTools
                Mock Start-Sleep {} -ModuleName ServiceDeskTools

                { Invoke-SDRequest -Method 'GET' -Path '/fail' } | Should -Throw 'ChaosMode:'

                Assert-MockCalled Start-Sleep -ModuleName ServiceDeskTools -ParameterFilter { $Milliseconds -eq 1000 } -Times 1

                Remove-Item env:SD_API_TOKEN
                Remove-Item env:ST_CHAOS_MODE
            }
        }
    }
}
