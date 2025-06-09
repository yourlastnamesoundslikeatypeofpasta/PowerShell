Describe 'STPlatform Module' {
    BeforeAll {
        Import-Module $PSScriptRoot/../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../src/Telemetry/Telemetry.psd1 -Force
        Import-Module $PSScriptRoot/../src/STPlatform/STPlatform.psd1 -Force
    }

    It 'exports Connect-STPlatform' {
        (Get-Command -Module STPlatform).Name | Should -Contain 'Connect-STPlatform'
    }

    It 'includes Vault parameter' {
        (Get-Command Connect-STPlatform).Parameters.Keys | Should -Contain 'Vault'
    }

    It 'loads secrets when variables missing' {
        InModuleScope STPlatform {
            Remove-Item env:SPTOOLS_CLIENT_ID -ErrorAction SilentlyContinue
            Mock Get-Secret { 'fromvault' }
            Connect-STPlatform -Mode Cloud -Vault 'Test'
            Assert-MockCalled Get-Secret -ParameterFilter { $Name -eq 'SPTOOLS_CLIENT_ID' -and $Vault -eq 'Test' } -Times 1
            $env:SPTOOLS_CLIENT_ID | Should -Be 'fromvault'
            Remove-Item env:SPTOOLS_CLIENT_ID -ErrorAction SilentlyContinue
        }
    }

    Context 'Mode connections' {
        It 'initializes Cloud mode and logs metrics' {
            InModuleScope STPlatform {
                function Install-Module {}
                function Import-Module {}
                function Get-Module { param($Name,[switch]$ListAvailable) }
                function Connect-MgGraph {}
                function Connect-ExchangeOnline {}
                Mock Install-Module {}
                Mock Import-Module {}
                Mock Get-Module { $null }
                Mock Connect-MgGraph {}
                Mock Connect-ExchangeOnline {}

                $log = Join-Path ([IO.Path]::GetTempPath()) ([IO.Path]::GetRandomFileName())
                try {
                    $env:ST_ENABLE_TELEMETRY = '1'
                    $env:ST_TELEMETRY_PATH = $log
                    Connect-STPlatform -Mode Cloud -InstallMissing
                    Assert-MockCalled Connect-MgGraph -Times 1
                    Assert-MockCalled Connect-ExchangeOnline -Times 1
                    Assert-MockCalled Install-Module -Times 2
                    (Get-Content $log | Measure-Object -Line).Lines | Should -Be 1
                    (Get-Content $log | ConvertFrom-Json).MetricName | Should -Be 'Connect-STPlatform'
                } finally {
                    Remove-Item $log -ErrorAction SilentlyContinue
                    Remove-Item env:ST_ENABLE_TELEMETRY -ErrorAction SilentlyContinue
                    Remove-Item env:ST_TELEMETRY_PATH -ErrorAction SilentlyContinue
                }
            }
        }

        It 'initializes Hybrid mode and logs metrics' {
            InModuleScope STPlatform {
                function Install-Module {}
                function Import-Module {}
                function Get-Module { param($Name,[switch]$ListAvailable) }
                function Connect-MgGraph {}
                function Connect-ExchangeOnline {}
                Mock Install-Module {}
                Mock Import-Module {}
                Mock Get-Module { $null }
                Mock Connect-MgGraph {}
                Mock Connect-ExchangeOnline {}

                $log = Join-Path ([IO.Path]::GetTempPath()) ([IO.Path]::GetRandomFileName())
                try {
                    $env:ST_ENABLE_TELEMETRY = '1'
                    $env:ST_TELEMETRY_PATH = $log
                    Connect-STPlatform -Mode Hybrid -InstallMissing
                    Assert-MockCalled Connect-MgGraph -Times 1
                    Assert-MockCalled Connect-ExchangeOnline -Times 1
                    Assert-MockCalled Install-Module -Times 3
                    (Get-Content $log | Measure-Object -Line).Lines | Should -Be 1
                    (Get-Content $log | ConvertFrom-Json).MetricName | Should -Be 'Connect-STPlatform'
                } finally {
                    Remove-Item $log -ErrorAction SilentlyContinue
                    Remove-Item env:ST_ENABLE_TELEMETRY -ErrorAction SilentlyContinue
                    Remove-Item env:ST_TELEMETRY_PATH -ErrorAction SilentlyContinue
                }
            }
        }

        It 'initializes OnPrem mode and logs metrics' {
            InModuleScope STPlatform {
                function Install-Module {}
                function Import-Module {}
                function Get-Module { param($Name,[switch]$ListAvailable) }
                function Get-Command { param($Name) if ($Name -eq 'Connect-ExchangeServer') { @{ Name = $Name } } }
                function Connect-ExchangeServer {}
                Mock Install-Module {}
                Mock Import-Module {}
                Mock Get-Module { $null }
                Mock Get-Command { @{ Name = $Name } }
                Mock Connect-ExchangeServer {}

                $log = Join-Path ([IO.Path]::GetTempPath()) ([IO.Path]::GetRandomFileName())
                try {
                    $env:ST_ENABLE_TELEMETRY = '1'
                    $env:ST_TELEMETRY_PATH = $log
                    Connect-STPlatform -Mode OnPrem -InstallMissing
                    Assert-MockCalled Connect-ExchangeServer -Times 1 -ParameterFilter { $Auto }
                    Assert-MockCalled Install-Module -Times 2
                    (Get-Content $log | Measure-Object -Line).Lines | Should -Be 1
                    (Get-Content $log | ConvertFrom-Json).MetricName | Should -Be 'Connect-STPlatform'
                } finally {
                    Remove-Item $log -ErrorAction SilentlyContinue
                    Remove-Item env:ST_ENABLE_TELEMETRY -ErrorAction SilentlyContinue
                    Remove-Item env:ST_TELEMETRY_PATH -ErrorAction SilentlyContinue
                }
            }
        }
    }
}
