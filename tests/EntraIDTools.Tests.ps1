. $PSScriptRoot/TestHelpers.ps1

Describe 'EntraIDTools Module' {
    BeforeAll {
        if (-not (Get-Module -ListAvailable -Name 'MSAL.PS')) {
            try { Install-Module -Name 'MSAL.PS' -Scope CurrentUser -Force } catch {}
        }
        Import-Module MSAL.PS -ErrorAction SilentlyContinue
        Import-Module $PSScriptRoot/../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../src/Telemetry/Telemetry.psd1 -Force
        Import-Module $PSScriptRoot/../src/EntraIDTools/EntraIDTools.psd1 -Force
        . $PSScriptRoot/../src/EntraIDTools/Private/Get-GraphAccessToken.ps1
    }

    Context 'Exported commands' {
        It 'Exports Get-GraphUserDetails' {
            (Get-Command -Module EntraIDTools).Name | Should -Contain 'Get-GraphUserDetails'
        }
        It 'Exports Get-GraphGroupDetails' {
            (Get-Command -Module EntraIDTools).Name | Should -Contain 'Get-GraphGroupDetails'
        }
    }

    Context 'Logging and telemetry' {
        It 'Logs requests and writes telemetry' {
            Mock Get-GraphAccessToken { 't' } -ModuleName EntraIDTools
            Mock Invoke-RestMethod { @{ id='1'; displayName='User'; userPrincipalName='u' } } -ModuleName EntraIDTools -ParameterFilter { $Method -eq 'GET' }
            Mock Write-STLog {} -ModuleName EntraIDTools
            Mock Write-STTelemetryEvent {} -ModuleName EntraIDTools
            Get-GraphUserDetails -UserPrincipalName 'u' -TenantId 'tid' -ClientId 'cid'
            Assert-MockCalled Write-STLog -ModuleName EntraIDTools -Times 1
            Assert-MockCalled Write-STTelemetryEvent -ModuleName EntraIDTools -Times 1
        }

        It 'Logs group requests and writes telemetry' {
            Mock Get-GraphAccessToken { 't' } -ModuleName EntraIDTools
            Mock Invoke-RestMethod { @{ displayName='G'; description='D'; value=@(@{displayName='U'}) } } -ModuleName EntraIDTools -ParameterFilter { $Method -eq 'GET' }
            Mock Write-STLog {} -ModuleName EntraIDTools
            Mock Write-STTelemetryEvent {} -ModuleName EntraIDTools
            Get-GraphGroupDetails -GroupId 'gid' -TenantId 'tid' -ClientId 'cid'
            Assert-MockCalled Write-STLog -ModuleName EntraIDTools -Times 1
            Assert-MockCalled Write-STTelemetryEvent -ModuleName EntraIDTools -Times 1
        }
    }

    Context 'Cloud parameter' {
        It 'uses AD for user details when Cloud is AD' {
            Mock Get-ADUser { @{ UserPrincipalName='u'; Name='User'; MemberOf=@(); LastLogonDate=(Get-Date) } } -ModuleName EntraIDTools
            $res = Get-GraphUserDetails -UserPrincipalName 'u' -TenantId 'tid' -ClientId 'cid' -Cloud 'AD'
            Assert-MockCalled Get-ADUser -ModuleName EntraIDTools -Times 1
        }
        It 'uses AD for group details when Cloud is AD' {
            Mock Get-ADGroup { @{ Name='G'; Description='D' } } -ModuleName EntraIDTools
            Mock Get-ADGroupMember { @{Name='User'} } -ModuleName EntraIDTools
            $res = Get-GraphGroupDetails -GroupId 'gid' -TenantId 'tid' -ClientId 'cid' -Cloud 'AD'
            Assert-MockCalled Get-ADGroup -ModuleName EntraIDTools -Times 1
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
            Mock Get-GraphAccessToken { 't' } -ModuleName EntraIDTools
            Mock Invoke-RestMethod { throw 'bad' } -ModuleName EntraIDTools -ParameterFilter { $Method -eq 'GET' }
            Mock Write-STTelemetryEvent {} -ModuleName EntraIDTools
            { Get-GraphUserDetails -UserPrincipalName 'u' -TenantId 'tid' -ClientId 'cid' } | Should -Throw
            Assert-MockCalled Write-STTelemetryEvent -ModuleName EntraIDTools -Times 1 -ParameterFilter { $Result -eq 'Failure' }
        }

        It 'logs group detail failures' {
            Mock Get-GraphAccessToken { 't' } -ModuleName EntraIDTools
            Mock Invoke-RestMethod { throw 'bad' } -ModuleName EntraIDTools -ParameterFilter { $Method -eq 'GET' }
            Mock Write-STTelemetryEvent {} -ModuleName EntraIDTools
            { Get-GraphGroupDetails -GroupId 'gid' -TenantId 'tid' -ClientId 'cid' } | Should -Throw
            Assert-MockCalled Write-STTelemetryEvent -ModuleName EntraIDTools -Times 1 -ParameterFilter { $Result -eq 'Failure' }
        }
    }
}
