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

    Safe-It 'exports Connect-EntraID' {
        (Get-Command -Module STPlatform).Name | Should -Contain 'Connect-EntraID'
    }

    Safe-It 'Connect-EntraID includes Vault parameter' {
        (Get-Command Connect-EntraID).Parameters.Keys | Should -Contain 'Vault'
    }

    Safe-It 'includes Vault parameter' {
        (Get-Command Connect-STPlatform).Parameters.Keys | Should -Contain 'Vault'
    }

    Safe-It 'includes ChaosMode parameter' {
        (Get-Command Connect-STPlatform).Parameters.Keys | Should -Contain 'ChaosMode'
    }

    Safe-It 'loads secrets when variables missing' {
        InModuleScope STPlatform {
            Import-Module $PSScriptRoot/../src/Telemetry/Telemetry.psd1 -Force
            Mock Connect-MgGraph {}
            Mock Connect-ExchangeOnline {}
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
            Import-Module $PSScriptRoot/../src/Telemetry/Telemetry.psd1 -Force
            Mock Connect-MgGraph {}
            Mock Connect-ExchangeOnline {}
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
            Import-Module $PSScriptRoot/../src/Telemetry/Telemetry.psd1 -Force
            Mock Connect-MgGraph {}
            Mock Connect-ExchangeOnline {}
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
            Import-Module $PSScriptRoot/../src/Telemetry/Telemetry.psd1 -Force
            Mock Connect-MgGraph {}
            Mock Connect-ExchangeOnline {}
            Remove-Item env:SPTOOLS_TENANT_ID -ErrorAction SilentlyContinue
            Mock Get-Secret { 'tenant' }
            Mock Write-STStatus {}

            Connect-STPlatform -Mode Cloud -Vault LogVault

            Assert-MockCalled Write-STStatus -ParameterFilter { $Message -eq 'Loaded SPTOOLS_TENANT_ID from vault' -and $Level -eq 'SUB' -and $Log } -Times 1
            Remove-Item env:SPTOOLS_TENANT_ID -ErrorAction SilentlyContinue
        }
    }

    Context 'Chaos mode' {
        Safe-It 'passes ChaosMode to Invoke-STRequest' {
            InModuleScope STPlatform {
                Mock Connect-MgGraph {}
                Mock Connect-ExchangeOnline {}
                Mock Invoke-STRequest {}
                Connect-STPlatform -Mode Cloud -ChaosMode
                Assert-MockCalled Invoke-STRequest -Times 1 -ParameterFilter { $ChaosMode -eq $true }
            }
        }

        Safe-It 'honors ST_CHAOS_MODE environment variable' {
            InModuleScope STPlatform {
                Mock Connect-MgGraph {}
                Mock Connect-ExchangeOnline {}
                Mock Invoke-STRequest {}
                try {
                    $env:ST_CHAOS_MODE = '1'
                    Connect-STPlatform -Mode Cloud
                } finally {
                    Remove-Item env:ST_CHAOS_MODE -ErrorAction SilentlyContinue
                }
                Assert-MockCalled Invoke-STRequest -Times 1
            }
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

    Context 'Connect-EntraID' {
        Safe-It 'connects using environment variables' {
            InModuleScope STPlatform {
                Mock Connect-MgGraph {}
                $env:GRAPH_TENANT_ID = 'tidEnv'
                $env:GRAPH_CLIENT_ID = 'cidEnv'
                $env:GRAPH_CLIENT_SECRET = 'secEnv'
                Connect-EntraID -Scopes 'User.Read'
                Assert-MockCalled Connect-MgGraph -Times 1 -ParameterFilter { $TenantId -eq 'tidEnv' -and $ClientId -eq 'cidEnv' -and $ClientSecret -eq 'secEnv' -and $Scopes -eq 'User.Read' }
                foreach ($n in 'GRAPH_TENANT_ID','GRAPH_CLIENT_ID','GRAPH_CLIENT_SECRET') { Remove-Item "env:$n" -ErrorAction SilentlyContinue }
            }
        }

        Safe-It 'loads GRAPH variables from vault' {
            InModuleScope STPlatform {
                Mock Connect-MgGraph {}
                foreach ($n in 'GRAPH_TENANT_ID','GRAPH_CLIENT_ID','GRAPH_CLIENT_SECRET') { Remove-Item "env:$n" -ErrorAction SilentlyContinue }
                Mock Get-Secret {
                    switch ($Name) {
                        'GRAPH_TENANT_ID'     { 'tid' }
                        'GRAPH_CLIENT_ID'     { 'cid' }
                        'GRAPH_CLIENT_SECRET' { 'sec' }
                    }
                }
                Connect-EntraID -Vault GraphVault
                foreach ($n in 'GRAPH_TENANT_ID','GRAPH_CLIENT_ID','GRAPH_CLIENT_SECRET') {
                    Assert-MockCalled Get-Secret -ParameterFilter { $Name -eq $n -and $Vault -eq 'GraphVault' } -Times 1
                }
                Assert-MockCalled Connect-MgGraph -Times 1 -ParameterFilter { $TenantId -eq 'tid' -and $ClientId -eq 'cid' -and $ClientSecret -eq 'sec' }
                foreach ($n in 'GRAPH_TENANT_ID','GRAPH_CLIENT_ID','GRAPH_CLIENT_SECRET') { Remove-Item "env:$n" -ErrorAction SilentlyContinue }
            }
        }

        Safe-It 'records failure when Connect-MgGraph throws' {
            InModuleScope STPlatform {
                Mock Connect-MgGraph { throw 'boom' }
                Mock Write-STLog {}
                foreach ($n in 'GRAPH_TENANT_ID','GRAPH_CLIENT_ID','GRAPH_CLIENT_SECRET') { $env:$n = $n.ToLower() }
                $log = Join-Path ([IO.Path]::GetTempPath()) ([IO.Path]::GetRandomFileName())
                try {
                    $env:ST_ENABLE_TELEMETRY = '1'
                    $env:ST_TELEMETRY_PATH = $log
                    { Connect-EntraID } | Should -Throw
                    Assert-MockCalled Write-STLog -Times 1 -ParameterFilter { $Level -eq 'ERROR' -and $Message -like 'Connect-EntraID failed:*' }
                    (Get-Content $log | Measure-Object -Line).Lines | Should -Be 1
                    $json = Get-Content $log | ConvertFrom-Json
                    $json.Details.Result | Should -Be 'Failure'
                } finally {
                    Remove-Item $log -ErrorAction SilentlyContinue
                    Remove-Item env:ST_ENABLE_TELEMETRY -ErrorAction SilentlyContinue
                    Remove-Item env:ST_TELEMETRY_PATH -ErrorAction SilentlyContinue
                    foreach ($n in 'GRAPH_TENANT_ID','GRAPH_CLIENT_ID','GRAPH_CLIENT_SECRET') { Remove-Item "env:$n" -ErrorAction SilentlyContinue }
                }
            }
        }
    }

    Context 'Connect-EntraID validation' {
        Safe-It 'throws when TenantId missing and env vars absent' {
            InModuleScope STPlatform {
                Mock Connect-MgGraph {}
                Mock Get-Secret { $null }
                foreach ($n in 'GRAPH_TENANT_ID','GRAPH_CLIENT_ID','GRAPH_CLIENT_SECRET') { Remove-Item "env:$n" -ErrorAction SilentlyContinue }
                { Connect-EntraID -ClientId 'cid' } | Should -Throw 'TenantId is required. Provide -TenantId or set GRAPH_TENANT_ID.'
                foreach ($n in 'GRAPH_TENANT_ID','GRAPH_CLIENT_ID','GRAPH_CLIENT_SECRET') { Remove-Item "env:$n" -ErrorAction SilentlyContinue }
            }
        }

        Safe-It 'throws when ClientId missing and env vars absent' {
            InModuleScope STPlatform {
                Mock Connect-MgGraph {}
                Mock Get-Secret { $null }
                foreach ($n in 'GRAPH_TENANT_ID','GRAPH_CLIENT_ID','GRAPH_CLIENT_SECRET') { Remove-Item "env:$n" -ErrorAction SilentlyContinue }
                { Connect-EntraID -TenantId 'tid' } | Should -Throw 'ClientId is required. Provide -ClientId or set GRAPH_CLIENT_ID.'
                foreach ($n in 'GRAPH_TENANT_ID','GRAPH_CLIENT_ID','GRAPH_CLIENT_SECRET') { Remove-Item "env:$n" -ErrorAction SilentlyContinue }
            }
        }
    }
}
