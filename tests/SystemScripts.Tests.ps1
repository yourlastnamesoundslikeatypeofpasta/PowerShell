Describe 'System Scripts' {
    BeforeAll {
        . "$PSScriptRoot/../scripts/Get-NetworkShares.ps1"
        . "$PSScriptRoot/../scripts/Get-FailedLogins.ps1"
        . "$PSScriptRoot/../scripts/Set-TimeZoneEasternStandardTime.ps1"
    }

    Context 'Get-NetworkShares' {
        BeforeEach {
            function Get-CimInstance {}
            function Write-STStatus {}
            Mock Get-CimInstance {
                @(
                    [pscustomobject]@{ Name='Share1'; Path='C:\\Share1'; Description='d1'; Type=0 }
                    [pscustomobject]@{ Name='Share2'; Path='D:\\Share2'; Description='d2'; Type=1 }
                )
            }
            Mock Write-STStatus {}
        }
        It 'returns network share objects' {
            $result = Get-NetworkShares -ComputerName 'PC1'
            $result.ComputerName | Should -Be 'PC1'
            $result.Shares.Count | Should -Be 2
        }
    }

    Context 'Get-FailedLogins' {
        BeforeEach {
            function Get-WinEvent {}
            function Write-STStatus {}
            Mock Get-WinEvent {
                @(
                    [pscustomobject]@{ TimeCreated='t1'; Message='m1' }
                    [pscustomobject]@{ TimeCreated='t2'; Message='m2' }
                )
            }
            Mock Write-STStatus {}
        }
        It 'retrieves failed login events' {
            $result = Get-FailedLogins -ComputerName 'PC2'
            $result.Count | Should -Be 2
        }
    }

    Context 'Set-TimeZoneEasternStandardTime' {
        BeforeEach {
            $script:tz = $null
            function Set-TimeZone { param([string]$ID) $script:tz = $ID }
            function Write-STStatus {}
        }
        It 'calls Set-TimeZone with the EST identifier' {
            Set-TimeZoneEasternStandardTime
            $script:tz | Should -Be 'Eastern Standard Time'
        }
    }

    Context 'ProductKey script' {
        BeforeEach {
            function Get-CimInstance {}
            function Write-STStatus {}
            Mock Get-CimInstance { [pscustomobject]@{ OA3xOriginalProductKey = 'AAAAA-BBBBB-CCCCC-DDDDD-EEEEE' } }
            Mock Write-STStatus {}
        }
        It 'writes the product key to output file' {
            $temp = Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName())
            & $PSScriptRoot/../scripts/ProductKey.ps1 -OutputPath $temp
            (Get-Content $temp) | Should -Be 'AAAAA-BBBBB-CCCCC-DDDDD-EEEEE'
            Remove-Item $temp -ErrorAction SilentlyContinue
        }
    }
}
