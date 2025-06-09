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
        It 'Exports Get-UserInfoHybrid' {
            (Get-Command -Module EntraIDTools).Name | Should -Contain 'Get-UserInfoHybrid'
        }
        It 'Exports Get-GraphSignInLogs' {
            (Get-Command -Module EntraIDTools).Name | Should -Contain 'Get-GraphSignInLogs'
        }
    }

    Context 'Logging and telemetry' {
        It 'Logs requests and writes telemetry' {
            Mock Get-GraphAccessToken { 't' } -ModuleName EntraIDTools
            Mock Invoke-STRequest { @{ id='1'; displayName='User'; userPrincipalName='u' } } -ModuleName EntraIDTools -ParameterFilter { $Method -eq 'GET' }
            Mock Write-STLog {} -ModuleName EntraIDTools
            Mock Write-STTelemetryEvent {} -ModuleName EntraIDTools
            Get-GraphUserDetails -UserPrincipalName 'u' -TenantId 'tid' -ClientId 'cid'
            Assert-MockCalled Write-STLog -ModuleName EntraIDTools -Times 1
            Assert-MockCalled Write-STTelemetryEvent -ModuleName EntraIDTools -Times 1
        }

        It 'Logs group requests and writes telemetry' {
            Mock Get-GraphAccessToken { 't' } -ModuleName EntraIDTools
            Mock Invoke-STRequest { @{ displayName='G'; description='D'; value=@(@{displayName='U'}) } } -ModuleName EntraIDTools -ParameterFilter { $Method -eq 'GET' }
            Mock Write-STLog {} -ModuleName EntraIDTools
            Mock Write-STTelemetryEvent {} -ModuleName EntraIDTools
            Get-GraphGroupDetails -GroupId 'gid' -TenantId 'tid' -ClientId 'cid'
            Assert-MockCalled Write-STLog -ModuleName EntraIDTools -Times 1
            Assert-MockCalled Write-STTelemetryEvent -ModuleName EntraIDTools -Times 1
        }
        It 'Logs hybrid requests and writes telemetry' {
            Mock Get-GraphUserDetails { @{ UserPrincipalName='u'; DisplayName='User'; Licenses='L'; Groups='G'; LastSignIn='t' } } -ModuleName EntraIDTools
            Mock Get-ADUser { [pscustomobject]@{ SamAccountName='sam'; Enabled=$true } } -ModuleName EntraIDTools
            Mock Write-STLog {} -ModuleName EntraIDTools
            Mock Write-STTelemetryEvent {} -ModuleName EntraIDTools
            Get-UserInfoHybrid -UserPrincipalName 'u' -TenantId 'tid' -ClientId 'cid'
            Assert-MockCalled Write-STLog -ModuleName EntraIDTools -Times 1
            Assert-MockCalled Write-STTelemetryEvent -ModuleName EntraIDTools -Times 1
        }
        It 'Logs sign-in log requests and writes telemetry' {
            Mock Get-GraphAccessToken { 't' } -ModuleName EntraIDTools
            Mock Invoke-RestMethod { @{ value=@(@{id='1'}) } } -ModuleName EntraIDTools -ParameterFilter { $Method -eq 'GET' }
            Mock Write-STLog {} -ModuleName EntraIDTools
            Mock Write-STTelemetryEvent {} -ModuleName EntraIDTools
            Get-GraphSignInLogs -UserPrincipalName 'u' -TenantId 'tid' -ClientId 'cid'
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
            try {
                function Get-MsalToken { @{ AccessToken='tok'; ExpiresOn=(Get-Date).AddMinutes(30) } }
                $token = Get-GraphAccessToken
                $token | Should -Be 'tok'
            } finally {
                Remove-Item env:GRAPH_TENANT_ID -ErrorAction SilentlyContinue
                Remove-Item env:GRAPH_CLIENT_ID -ErrorAction SilentlyContinue
                Remove-Item env:GRAPH_CLIENT_SECRET -ErrorAction SilentlyContinue
            }
        }
    }

    Context 'Token retrieval' {
        It 'invokes Get-MsalToken when no cache available' {
            $called = $false
            function Get-MsalToken { $script:called = $true; @{ AccessToken='tok'; ExpiresOn=(Get-Date).AddMinutes(30) } }
            $script:called = $false
            $token = Get-GraphAccessToken -TenantId 'tid' -ClientId 'cid'
            $token | Should -Be 'tok'
            $script:called | Should -Be $true
        }
    }

    Context 'Failure telemetry' {
        It 'logs user detail failures' {
            Mock Get-GraphAccessToken { 't' } -ModuleName EntraIDTools
            Mock Invoke-STRequest { throw 'bad' } -ModuleName EntraIDTools -ParameterFilter { $Method -eq 'GET' }
            Mock Write-STTelemetryEvent {} -ModuleName EntraIDTools
            { Get-GraphUserDetails -UserPrincipalName 'u' -TenantId 'tid' -ClientId 'cid' } | Should -Throw
            Assert-MockCalled Write-STTelemetryEvent -ModuleName EntraIDTools -Times 1 -ParameterFilter { $Result -eq 'Failure' }
        }

        It 'logs group detail failures' {
            Mock Get-GraphAccessToken { 't' } -ModuleName EntraIDTools
            Mock Invoke-STRequest { throw 'bad' } -ModuleName EntraIDTools -ParameterFilter { $Method -eq 'GET' }
            Mock Write-STTelemetryEvent {} -ModuleName EntraIDTools
            { Get-GraphGroupDetails -GroupId 'gid' -TenantId 'tid' -ClientId 'cid' } | Should -Throw
            Assert-MockCalled Write-STTelemetryEvent -ModuleName EntraIDTools -Times 1 -ParameterFilter { $Result -eq 'Failure' }
        }
        It 'logs hybrid failures' {
            Mock Get-GraphUserDetails { throw 'bad' } -ModuleName EntraIDTools
            Mock Write-STTelemetryEvent {} -ModuleName EntraIDTools
            { Get-UserInfoHybrid -UserPrincipalName 'u' -TenantId 'tid' -ClientId 'cid' } | Should -Throw
            Assert-MockCalled Write-STTelemetryEvent -ModuleName EntraIDTools -Times 1 -ParameterFilter { $Result -eq 'Failure' }
        }
        It 'logs sign-in log failures' {
            Mock Get-GraphAccessToken { 't' } -ModuleName EntraIDTools
            Mock Invoke-RestMethod { throw 'bad' } -ModuleName EntraIDTools -ParameterFilter { $Method -eq 'GET' }
            Mock Write-STTelemetryEvent {} -ModuleName EntraIDTools
            { Get-GraphSignInLogs -TenantId 'tid' -ClientId 'cid' } | Should -Throw
            Assert-MockCalled Write-STTelemetryEvent -ModuleName EntraIDTools -Times 1 -ParameterFilter { $Result -eq 'Failure' }
        }
    }
}
