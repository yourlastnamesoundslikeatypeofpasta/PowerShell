. $PSScriptRoot/TestHelpers.ps1
Describe 'STCore Helper Functions' {
    BeforeAll {
        Import-Module $PSScriptRoot/../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../src/STCore/STCore.psd1 -Force
    }

    Safe-It 'Assert-ParameterNotNull throws on null' {
        { Assert-ParameterNotNull $null 'Param' } | Should -Throw
    }

    Context 'Get-STConfig' {
        Safe-It 'reads JSON files' {
            $path = Join-Path $TestDrive 'c.json'
            Set-Content -Path $path -Value '{"x":42}'
            try {
                $cfg = Get-STConfig -Path $path
                $cfg.x | Should -Be 42
            } finally {
                Remove-Item $path -ErrorAction SilentlyContinue
            }
        }

        Safe-It 'reads PSD1 files' {
            $path = Join-Path $TestDrive 'c.psd1'
            Set-Content -Path $path -Value '@{ y = 99 }'
            try {
                $cfg = Get-STConfig -Path $path
                $cfg.y | Should -Be 99
            } finally {
                Remove-Item $path -ErrorAction SilentlyContinue
            }
        }

        Safe-It 'returns empty for missing file' {
            $path = Join-Path $TestDrive 'nofile.json'
            $cfg = Get-STConfig -Path $path
            $cfg | Should -BeOfType 'hashtable'
            $cfg.Count | Should -Be 0
        }
    }

    Context 'Write-STDebug' {
        Safe-It 'emits output only when ST_DEBUG=1' {
            InModuleScope STCore {
                Mock Write-STStatus {}
                Mock Write-STLog {}
                try {
                    $env:ST_DEBUG = '1'
                    Write-STDebug 'msg'
                    Remove-Item env:ST_DEBUG
                    Write-STDebug 'msg'
                    Assert-MockCalled Write-STStatus -Times 1 -ParameterFilter { $Message -eq '[DEBUG] msg' }
                    Assert-MockCalled Write-STLog -Times 1 -ParameterFilter { $Message -eq '[DEBUG] msg' }
                } finally {
                    Remove-Item env:ST_DEBUG -ErrorAction SilentlyContinue
                }
            }
        }
    }

    Context 'Test-IsElevated' {
        Safe-It 'uses Windows APIs when IsWindows is true' {
            InModuleScope STCore {
                Set-Variable -Name IsWindows -Value $true -Scope Script -Force
                Mock id { 0 }
                { Test-IsElevated } | Should -Throw
                Assert-MockCalled id -Times 0
            }
        }
        Safe-It 'checks uid 0 when IsWindows is false' {
            InModuleScope STCore {
                Set-Variable -Name IsWindows -Value $false -Scope Script -Force
                Mock id { '0' }
                $result = Test-IsElevated
                Assert-MockCalled id -Times 1
                $result | Should -Be $true
            }
        }
    }

    Context 'Import-STCsv' {
        Safe-It 'throws when file missing' {
            $path = Join-Path $TestDrive 'missing.csv'
            { Import-STCsv -Path $path } | Should -Throw
        }
        Safe-It 'returns imported objects' {
            $path = Join-Path $TestDrive 'good.csv'
            "UPN`nuser@contoso.com" | Set-Content -Path $path
            try {
                $res = Import-STCsv -Path $path
                $res[0].UPN | Should -Be 'user@contoso.com'
            } finally {
                Remove-Item $path -ErrorAction SilentlyContinue
            }
        }
    }

    Context 'Invoke-STRequest' {
        Safe-It 'invokes once on success' {
            InModuleScope STCore {
                Mock Write-STLog {}
                Mock Invoke-RestMethod { @{ ok = 1 } }
                $result = Invoke-STRequest -Method GET -Uri 'https://example.com'
                $result.ok | Should -Be 1
                Assert-MockCalled Invoke-RestMethod -Times 1 -ParameterFilter { $Method -eq 'GET' -and $Uri -eq 'https://example.com' }
            }
        }

        Safe-It 'retries on server error' {
            InModuleScope STCore {
                Mock Write-STLog {}
                Mock Start-Sleep {}
                $script:called = 0
                Mock Invoke-RestMethod {
                    if ($script:called -eq 0) {
                        $script:called = 1
                        $ex = [System.Net.WebException]::new('err')
                        $resp = [pscustomobject]@{ StatusCode = [System.Net.HttpStatusCode]::InternalServerError; Headers = @{} }
                        $ex | Add-Member -NotePropertyName Response -NotePropertyValue $resp -Force
                        throw $ex
                    } else {
                        @{ ok = 1 }
                    }
                }
                $result = Invoke-STRequest -Method GET -Uri 'https://example.com'
                $result.ok | Should -Be 1
                Assert-MockCalled Invoke-RestMethod -Times 2
                Assert-MockCalled Start-Sleep -Times 1
            }
        }

        Safe-It 'honors -ChaosMode' {
            InModuleScope STCore {
                Mock Write-STLog {}
                Mock Start-Sleep {}
                Mock Get-Random { param($Minimum,$Maximum) if ($Maximum -eq 1500) { return 600 } else { return 5 } }
                Mock Invoke-RestMethod {}
                { Invoke-STRequest -Method GET -Uri 'https://example.com' -ChaosMode } | Should -Throw '*ChaosMode*'
                Assert-MockCalled Invoke-RestMethod -Times 0
                Assert-MockCalled Start-Sleep -Times 1
            }
        }

        Safe-It 'honors ST_CHAOS_MODE environment variable' {
            InModuleScope STCore {
                Mock Write-STLog {}
                Mock Start-Sleep {}
                Mock Get-Random { param($Minimum,$Maximum) if ($Maximum -eq 1500) { return 500 } else { return 12 } }
                Mock Invoke-RestMethod {}
                try {
                    $env:ST_CHAOS_MODE = '1'
                    { Invoke-STRequest -Method GET -Uri 'https://example.com' } | Should -Throw '*ChaosMode*'
                } finally {
                    Remove-Item env:ST_CHAOS_MODE -ErrorAction SilentlyContinue
                }
                Assert-MockCalled Invoke-RestMethod -Times 0
                Assert-MockCalled Start-Sleep -Times 1
            }
        }
    }
}
