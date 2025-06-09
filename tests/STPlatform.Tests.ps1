. $PSScriptRoot/TestHelpers.ps1
Describe 'STPlatform Module' {
    BeforeAll {
        Import-Module $PSScriptRoot/../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../src/Telemetry/Telemetry.psd1 -Force
        Import-Module $PSScriptRoot/../src/STPlatform/STPlatform.psd1 -Force
    }

    Safe-It 'exports Connect-STPlatform' {
        (Get-Command -Module STPlatform).Name | Should -Contain 'Connect-STPlatform'
    }

    Safe-It 'includes Vault parameter' {
        (Get-Command Connect-STPlatform).Parameters.Keys | Should -Contain 'Vault'
    }

    Safe-It 'loads secrets when variables missing' {
        InModuleScope STPlatform {
            Remove-Item env:SPTOOLS_CLIENT_ID -ErrorAction SilentlyContinue
            Mock Get-Secret { 'fromvault' }
            Connect-STPlatform -Mode Cloud -Vault 'Test'
            Assert-MockCalled Get-Secret -ParameterFilter { $Name -eq 'SPTOOLS_CLIENT_ID' -and $Vault -eq 'Test' } -Times 1
            $env:SPTOOLS_CLIENT_ID | Should -Be 'fromvault'
            Remove-Item env:SPTOOLS_CLIENT_ID -ErrorAction SilentlyContinue
        }
    }

    Safe-It 'loads all required secrets from the vault' {
        InModuleScope STPlatform {
            $names = 'SPTOOLS_CLIENT_ID','SPTOOLS_TENANT_ID','SPTOOLS_CERT_PATH','SD_API_TOKEN','SD_BASE_URI'
            foreach ($n in $names) { Remove-Item "env:$n" -ErrorAction SilentlyContinue }

            Mock Get-Secret {
                switch ($Name) {
                    'SPTOOLS_CLIENT_ID'   { 'cid' }
                    'SPTOOLS_TENANT_ID'  { 'tenant' }
                    'SPTOOLS_CERT_PATH'  { 'cert' }
                    'SD_API_TOKEN'       { 'token' }
                    'SD_BASE_URI'        { 'uri' }
                }
            }

            Connect-STPlatform -Mode Cloud -Vault TestVault

            foreach ($n in $names) {
                Assert-MockCalled Get-Secret -ParameterFilter { $Name -eq $n -and $Vault -eq 'TestVault' } -Times 1
            }
            $env:SPTOOLS_CLIENT_ID  | Should -Be 'cid'
            $env:SPTOOLS_TENANT_ID | Should -Be 'tenant'
            $env:SPTOOLS_CERT_PATH | Should -Be 'cert'
            $env:SD_API_TOKEN      | Should -Be 'token'
            $env:SD_BASE_URI       | Should -Be 'uri'

            foreach ($n in $names) { Remove-Item "env:$n" -ErrorAction SilentlyContinue }
        }
    }


    It 'loads missing secrets when some variables exist' {
        InModuleScope STPlatform {
            $names = 'SPTOOLS_CLIENT_ID','SPTOOLS_TENANT_ID','SPTOOLS_CERT_PATH','SD_API_TOKEN','SD_BASE_URI'
            $env:SPTOOLS_CLIENT_ID = 'existing'
            $env:SD_BASE_URI = 'uri-env'
            foreach ($n in $names | Where-Object { $_ -notin 'SPTOOLS_CLIENT_ID','SD_BASE_URI' }) { Remove-Item "env:$n" -ErrorAction SilentlyContinue }

            Mock Get-Secret {
                switch ($Name) {
                    'SPTOOLS_TENANT_ID' { 'tenant' }
                    'SPTOOLS_CERT_PATH' { 'cert' }
                    'SD_API_TOKEN'      { 'token' }
                }
            }
            Mock Write-STStatus {}

            Connect-STPlatform -Mode Cloud -Vault CustomVault

            foreach ($n in 'SPTOOLS_TENANT_ID','SPTOOLS_CERT_PATH','SD_API_TOKEN') {
                Assert-MockCalled Get-Secret -ParameterFilter { $Name -eq $n -and $Vault -eq 'CustomVault' } -Times 1
            }
            foreach ($n in 'SPTOOLS_CLIENT_ID','SD_BASE_URI') {
                Assert-MockCalled Get-Secret -ParameterFilter { $Name -eq $n } -Times 0
            }

            $env:SPTOOLS_CLIENT_ID  | Should -Be 'existing'
            $env:SPTOOLS_TENANT_ID | Should -Be 'tenant'
            $env:SPTOOLS_CERT_PATH | Should -Be 'cert'
            $env:SD_API_TOKEN      | Should -Be 'token'
            $env:SD_BASE_URI       | Should -Be 'uri-env'

            foreach ($n in $names) { Remove-Item "env:$n" -ErrorAction SilentlyContinue }
        }
    }

    It 'logs secret retrieval with Write-STStatus' {
        InModuleScope STPlatform {
            Remove-Item env:SPTOOLS_TENANT_ID -ErrorAction SilentlyContinue
            Mock Get-Secret { 'tenant' }
            Mock Write-STStatus {}

            Connect-STPlatform -Mode Cloud -Vault LogVault

            Assert-MockCalled Write-STStatus -ParameterFilter { $Message -eq 'Loaded SPTOOLS_TENANT_ID from vault' -and $Level -eq 'SUB' -and $Log } -Times 1
            Remove-Item env:SPTOOLS_TENANT_ID -ErrorAction SilentlyContinue
        }
    }

    Context 'Mode connections' {
        Safe-It 'initializes Cloud mode and logs metrics' {
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
                    $json = Get-Content $log | ConvertFrom-Json
                    $json.MetricName | Should -Be 'Connect-STPlatform'
                    $json.Details.Modules | Should -Be @('Microsoft.Graph','ExchangeOnlineManagement')
                    $json.Details.Connections.Graph | Should -Be 'Success'
                    $json.Details.Connections.ExchangeOnline | Should -Be 'Success'
                } finally {
                    Remove-Item $log -ErrorAction SilentlyContinue
                    Remove-Item env:ST_ENABLE_TELEMETRY -ErrorAction SilentlyContinue
                    Remove-Item env:ST_TELEMETRY_PATH -ErrorAction SilentlyContinue
                }
            }
        }

        Safe-It 'initializes Hybrid mode and logs metrics' {
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
                    $json = Get-Content $log | ConvertFrom-Json
                    $json.MetricName | Should -Be 'Connect-STPlatform'
                    $json.Details.Modules | Should -Be @('Microsoft.Graph','ExchangeOnlineManagement','ActiveDirectory')
                    $json.Details.Connections.Graph | Should -Be 'Success'
                    $json.Details.Connections.ExchangeOnline | Should -Be 'Success'
                } finally {
                    Remove-Item $log -ErrorAction SilentlyContinue
                    Remove-Item env:ST_ENABLE_TELEMETRY -ErrorAction SilentlyContinue
                    Remove-Item env:ST_TELEMETRY_PATH -ErrorAction SilentlyContinue
                }
            }
        }

        Safe-It 'initializes OnPrem mode and logs metrics' {
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
                    $json = Get-Content $log | ConvertFrom-Json
                    $json.MetricName | Should -Be 'Connect-STPlatform'
                    $json.Details.Modules | Should -Be @('ActiveDirectory','ExchangePowerShell')
                    $json.Details.Connections.ExchangeOnPrem | Should -Be 'Success'
                } finally {
                    Remove-Item $log -ErrorAction SilentlyContinue
                    Remove-Item env:ST_ENABLE_TELEMETRY -ErrorAction SilentlyContinue
                    Remove-Item env:ST_TELEMETRY_PATH -ErrorAction SilentlyContinue
                }
            }
        }
    }
}
