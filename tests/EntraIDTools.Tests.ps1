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
        Safe-It 'Exports Get-GraphUserDetails' {
            (Get-Command -Module EntraIDTools).Name | Should -Contain 'Get-GraphUserDetails'
        }
        Safe-It 'Exports Get-GraphGroupDetails' {
            (Get-Command -Module EntraIDTools).Name | Should -Contain 'Get-GraphGroupDetails'
        }
        Safe-It 'Exports Get-UserInfoHybrid' {
            (Get-Command -Module EntraIDTools).Name | Should -Contain 'Get-UserInfoHybrid'
        }
        Safe-It 'Exports Get-GraphSignInLogs' {
            (Get-Command -Module EntraIDTools).Name | Should -Contain 'Get-GraphSignInLogs'
        }
        Safe-It 'Exports Watch-GraphSignIns' {
            (Get-Command -Module EntraIDTools).Name | Should -Contain 'Watch-GraphSignIns'
        }
    }

    Context 'Logging and telemetry' {
        Safe-It 'Logs requests and writes telemetry' {
            Mock Get-GraphAccessToken { 't' } -ModuleName EntraIDTools
            Mock Invoke-STRequest { @{ id='1'; displayName='User'; userPrincipalName='u' } } -ModuleName EntraIDTools -ParameterFilter { $Method -eq 'GET' }
            Mock Write-STLog {} -ModuleName EntraIDTools
            Mock Write-STTelemetryEvent {} -ModuleName EntraIDTools
            Get-GraphUserDetails -UserPrincipalName 'u' -TenantId 'tid' -ClientId 'cid'
            Assert-MockCalled Write-STLog -ModuleName EntraIDTools -Times 1
            Assert-MockCalled Write-STTelemetryEvent -ModuleName EntraIDTools -Times 1
        }

        Safe-It 'Logs group requests and writes telemetry' {
            Mock Get-GraphAccessToken { 't' } -ModuleName EntraIDTools
            Mock Invoke-STRequest { @{ displayName='G'; description='D'; value=@(@{displayName='U'}) } } -ModuleName EntraIDTools -ParameterFilter { $Method -eq 'GET' }
            Mock Write-STLog {} -ModuleName EntraIDTools
            Mock Write-STTelemetryEvent {} -ModuleName EntraIDTools
            Get-GraphGroupDetails -GroupId 'gid' -TenantId 'tid' -ClientId 'cid'
            Assert-MockCalled Write-STLog -ModuleName EntraIDTools -Times 1
            Assert-MockCalled Write-STTelemetryEvent -ModuleName EntraIDTools -Times 1
        }
        Safe-It 'Logs hybrid requests and writes telemetry' {
            Mock Get-GraphUserDetails { @{ UserPrincipalName='u'; DisplayName='User'; Licenses='L'; Groups='G'; LastSignIn='t' } } -ModuleName EntraIDTools
            Mock Get-ADUser { [pscustomobject]@{ SamAccountName='sam'; Enabled=$true } } -ModuleName EntraIDTools
            Mock Write-STLog {} -ModuleName EntraIDTools
            Mock Write-STTelemetryEvent {} -ModuleName EntraIDTools
            Get-UserInfoHybrid -UserPrincipalName 'u' -TenantId 'tid' -ClientId 'cid'
            Assert-MockCalled Write-STLog -ModuleName EntraIDTools -Times 1
            Assert-MockCalled Write-STTelemetryEvent -ModuleName EntraIDTools -Times 1
        }
        Safe-It 'Logs sign-in log requests and writes telemetry' {
            Mock Get-GraphAccessToken { 't' } -ModuleName EntraIDTools
            Mock Invoke-RestMethod { @{ value=@(@{id='1'}) } } -ModuleName EntraIDTools -ParameterFilter { $Method -eq 'GET' }
            Mock Write-STLog {} -ModuleName EntraIDTools
            Mock Write-STTelemetryEvent {} -ModuleName EntraIDTools
            Get-GraphSignInLogs -UserPrincipalName 'u' -TenantId 'tid' -ClientId 'cid'
            Assert-MockCalled Write-STLog -ModuleName EntraIDTools -Times 1
            Assert-MockCalled Write-STTelemetryEvent -ModuleName EntraIDTools -Times 1
        }
        Safe-It 'Creates tickets for risky sign-ins' {
            Mock Get-GraphSignInLogs { @(@{ userPrincipalName='u'; createdDateTime=(Get-Date); ipAddress='1.2.3.4'; riskLevelAggregated='high' }) } -ModuleName EntraIDTools
            Mock New-SDTicket {} -ModuleName EntraIDTools
            Watch-GraphSignIns -TenantId 'tid' -ClientId 'cid' -RequesterEmail 'r@contoso.com'
            Assert-MockCalled New-SDTicket -ModuleName EntraIDTools -Times 1
        }
    }

    Context 'Cloud parameter' {
        Safe-It 'uses AD for user details when Cloud is AD' {
            Mock Get-ADUser { @{ UserPrincipalName='u'; Name='User'; MemberOf=@(); LastLogonDate=(Get-Date) } } -ModuleName EntraIDTools
            $res = Get-GraphUserDetails -UserPrincipalName 'u' -TenantId 'tid' -ClientId 'cid' -Cloud 'AD'
            Assert-MockCalled Get-ADUser -ModuleName EntraIDTools -Times 1
        }
        Safe-It 'uses AD for group details when Cloud is AD' {
            Mock Get-ADGroup { @{ Name='G'; Description='D' } } -ModuleName EntraIDTools
            Mock Get-ADGroupMember { @{Name='User'} } -ModuleName EntraIDTools
            $res = Get-GraphGroupDetails -GroupId 'gid' -TenantId 'tid' -ClientId 'cid' -Cloud 'AD'
            Assert-MockCalled Get-ADGroup -ModuleName EntraIDTools -Times 1
        }
    }

    Context 'Environment variables' {
        Safe-It 'uses GRAPH_* variables when parameters missing' {
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

        It 'uses device login when switch provided' {
            $cache = Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName())
            try {
                $deviceUsed = $false
                function Get-MsalToken {
                    param([switch]$DeviceCode)
                    $script:deviceUsed = $DeviceCode.IsPresent
                    @{ AccessToken='tok'; ExpiresOn=(Get-Date).AddMinutes(30) }
                }
                $token = Get-GraphAccessToken -TenantId 'tid' -ClientId 'cid' -ClientSecret 'sec' -DeviceLogin -CachePath $cache
                $token | Should -Be 'tok'
                $script:deviceUsed | Should -Be $true
            } finally {
                Remove-Item $cache -ErrorAction SilentlyContinue
            }
        }
    }

    Context 'Token caching' {
        Safe-It 'returns cached token when not expired' {
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

        Safe-It 'refreshes expired token' {
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
        Safe-It 'logs user detail failures' {
            Mock Get-GraphAccessToken { 't' } -ModuleName EntraIDTools
            Mock Invoke-STRequest { throw 'bad' } -ModuleName EntraIDTools -ParameterFilter { $Method -eq 'GET' }
            Mock Write-STTelemetryEvent {} -ModuleName EntraIDTools
            { Get-GraphUserDetails -UserPrincipalName 'u' -TenantId 'tid' -ClientId 'cid' } | Should -Throw
            Assert-MockCalled Write-STTelemetryEvent -ModuleName EntraIDTools -Times 1 -ParameterFilter { $Result -eq 'Failure' }
        }

        Safe-It 'logs group detail failures' {
            Mock Get-GraphAccessToken { 't' } -ModuleName EntraIDTools
            Mock Invoke-STRequest { throw 'bad' } -ModuleName EntraIDTools -ParameterFilter { $Method -eq 'GET' }
            Mock Write-STTelemetryEvent {} -ModuleName EntraIDTools
            { Get-GraphGroupDetails -GroupId 'gid' -TenantId 'tid' -ClientId 'cid' } | Should -Throw
            Assert-MockCalled Write-STTelemetryEvent -ModuleName EntraIDTools -Times 1 -ParameterFilter { $Result -eq 'Failure' }
        }
        Safe-It 'logs hybrid failures' {
            Mock Get-GraphUserDetails { throw 'bad' } -ModuleName EntraIDTools
            Mock Write-STTelemetryEvent {} -ModuleName EntraIDTools
            { Get-UserInfoHybrid -UserPrincipalName 'u' -TenantId 'tid' -ClientId 'cid' } | Should -Throw
            Assert-MockCalled Write-STTelemetryEvent -ModuleName EntraIDTools -Times 1 -ParameterFilter { $Result -eq 'Failure' }
        }
        Safe-It 'logs sign-in log failures' {
            Mock Get-GraphAccessToken { 't' } -ModuleName EntraIDTools
            Mock Invoke-RestMethod { throw 'bad' } -ModuleName EntraIDTools -ParameterFilter { $Method -eq 'GET' }
            Mock Write-STTelemetryEvent {} -ModuleName EntraIDTools
            { Get-GraphSignInLogs -TenantId 'tid' -ClientId 'cid' } | Should -Throw
            Assert-MockCalled Write-STTelemetryEvent -ModuleName EntraIDTools -Times 1 -ParameterFilter { $Result -eq 'Failure' }
        }
    }
}
