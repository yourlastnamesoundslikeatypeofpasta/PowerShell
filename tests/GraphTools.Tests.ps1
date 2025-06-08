. $PSScriptRoot/TestHelpers.ps1

$msal = Get-Module MSAL.PS -ListAvailable
Describe 'GraphTools Module' -Skip:(-not $msal) {
    BeforeAll {
        Import-Module $PSScriptRoot/../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../src/Telemetry/Telemetry.psd1 -Force
        Import-Module MSAL.PS -ErrorAction Stop
        Import-Module $PSScriptRoot/../src/GraphTools/GraphTools.psd1 -Force
        . $PSScriptRoot/../src/GraphTools/Private/Get-GraphAccessToken.ps1
    }

    Context 'Module import' {
        It 'imports when MSAL.PS is installed' {
            Remove-Module GraphTools -ErrorAction SilentlyContinue
            Import-Module MSAL.PS -ErrorAction Stop
            { Import-Module $PSScriptRoot/../src/GraphTools/GraphTools.psd1 -Force } | Should -Not -Throw
        }
    }

    Context 'Exported commands' {
        It 'Exports Get-GraphUserDetails' {
            (Get-Command -Module GraphTools).Name | Should -Contain 'Get-GraphUserDetails'
        }
        It 'Exports Get-GraphGroupDetails' {
            (Get-Command -Module GraphTools).Name | Should -Contain 'Get-GraphGroupDetails'
        }
    }

    Context 'Logging and telemetry' {
        It 'Logs requests and writes telemetry' {
            Mock Get-GraphAccessToken { 't' } -ModuleName GraphTools
            Mock Invoke-RestMethod { @{ id='1'; displayName='User'; userPrincipalName='u' } } -ModuleName GraphTools -ParameterFilter { $Method -eq 'GET' }
            Mock Write-STLog {} -ModuleName GraphTools
            Mock Write-STTelemetryEvent {} -ModuleName GraphTools
            Get-GraphUserDetails -UserPrincipalName 'u' -TenantId 'tid' -ClientId 'cid'
            Assert-MockCalled Write-STLog -ModuleName GraphTools -Times 1
            Assert-MockCalled Write-STTelemetryEvent -ModuleName GraphTools -Times 1
        }

        It 'Logs group requests and writes telemetry' {
            Mock Get-GraphAccessToken { 't' } -ModuleName GraphTools
            Mock Invoke-RestMethod { @{ displayName='G'; description='D'; value=@(@{displayName='U'}) } } -ModuleName GraphTools -ParameterFilter { $Method -eq 'GET' }
            Mock Write-STLog {} -ModuleName GraphTools
            Mock Write-STTelemetryEvent {} -ModuleName GraphTools
            Get-GraphGroupDetails -GroupId 'gid' -TenantId 'tid' -ClientId 'cid'
            Assert-MockCalled Write-STLog -ModuleName GraphTools -Times 1
            Assert-MockCalled Write-STTelemetryEvent -ModuleName GraphTools -Times 1
        }
    }

    Context 'Environment variables' {
        It 'uses GRAPH_* variables when parameters missing' {
            $env:GRAPH_TENANT_ID = 'tidEnv'
            $env:GRAPH_CLIENT_ID = 'cidEnv'
            $env:GRAPH_CLIENT_SECRET = 'secEnv'
            $cache = Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName())
            try {
                function Get-MsalToken { @{ AccessToken='tok'; ExpiresOn=(Get-Date).AddMinutes(30) } }
                $token = Get-GraphAccessToken -CachePath $cache
                $token | Should -Be 'tok'
            } finally {
                Remove-Item env:GRAPH_TENANT_ID -ErrorAction SilentlyContinue
                Remove-Item env:GRAPH_CLIENT_ID -ErrorAction SilentlyContinue
                Remove-Item env:GRAPH_CLIENT_SECRET -ErrorAction SilentlyContinue
            }
        }
    }

    Context 'Token caching' {
        It 'returns cached token when not expired' {
            $cache = Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName())
            try {
                @{ accessToken='cached'; expiresOn=(Get-Date).AddMinutes(10) } |
                    ConvertTo-Json | Out-File -FilePath $cache -Encoding utf8
                $script:called = 0
                function Get-MsalToken { $script:called++; throw 'should not call' }
                $token = Get-GraphAccessToken -TenantId 'tid' -ClientId 'cid' -ClientSecret 'sec' -CachePath $cache
                $token | Should -Be 'cached'
                $script:called | Should -Be 0
            } finally {
                Remove-Item $cache -ErrorAction SilentlyContinue
            }
        }

        It 'refreshes expired token' {
            $cache = Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName())
            try {
                @{ accessToken='old'; expiresOn=(Get-Date).AddMinutes(-10) } |
                    ConvertTo-Json | Out-File -FilePath $cache -Encoding utf8
                $script:called = 0
                function Get-MsalToken { $script:called++; @{ AccessToken='new'; ExpiresOn=(Get-Date).AddMinutes(30) } }
                $token = Get-GraphAccessToken -TenantId 'tid' -ClientId 'cid' -ClientSecret 'sec' -CachePath $cache
                $token | Should -Be 'new'
                $script:called | Should -Be 1
                (Get-Content $cache | ConvertFrom-Json).accessToken | Should -Be 'new'
            } finally {
                Remove-Item $cache -ErrorAction SilentlyContinue
            }
        }
    }

    Context 'Failure telemetry' {
        It 'logs user detail failures' {
            Mock Get-GraphAccessToken { 't' } -ModuleName GraphTools
            Mock Invoke-RestMethod { throw 'bad' } -ModuleName GraphTools -ParameterFilter { $Method -eq 'GET' }
            Mock Write-STTelemetryEvent {} -ModuleName GraphTools
            { Get-GraphUserDetails -UserPrincipalName 'u' -TenantId 'tid' -ClientId 'cid' } | Should -Throw
            Assert-MockCalled Write-STTelemetryEvent -ModuleName GraphTools -Times 1 -ParameterFilter { $Result -eq 'Failure' }
        }

        It 'logs group detail failures' {
            Mock Get-GraphAccessToken { 't' } -ModuleName GraphTools
            Mock Invoke-RestMethod { throw 'bad' } -ModuleName GraphTools -ParameterFilter { $Method -eq 'GET' }
            Mock Write-STTelemetryEvent {} -ModuleName GraphTools
            { Get-GraphGroupDetails -GroupId 'gid' -TenantId 'tid' -ClientId 'cid' } | Should -Throw
            Assert-MockCalled Write-STTelemetryEvent -ModuleName GraphTools -Times 1 -ParameterFilter { $Result -eq 'Failure' }
        }
    }
}
