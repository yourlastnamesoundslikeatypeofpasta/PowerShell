Describe 'GraphTools Module' {
    BeforeAll {
        Import-Module $PSScriptRoot/../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../src/Telemetry/Telemetry.psd1 -Force
        Import-Module $PSScriptRoot/../src/GraphTools/GraphTools.psd1 -Force
    }

    Context 'Exported commands' {
        It 'Exports Get-GraphUserDetails' {
            (Get-Command -Module GraphTools).Name | Should -Contain 'Get-GraphUserDetails'
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

        It 'Logs failures to telemetry when REST call throws' {
            Mock Get-GraphAccessToken { 't' } -ModuleName GraphTools
            Mock Invoke-RestMethod { throw 'fail' } -ModuleName GraphTools -ParameterFilter { $Method -eq 'GET' }
            Mock Write-STLog {} -ModuleName GraphTools
            Mock Write-STTelemetryEvent {} -ModuleName GraphTools
            { Get-GraphUserDetails -UserPrincipalName 'u' -TenantId 'tid' -ClientId 'cid' } | Should -Throw
            Assert-MockCalled Write-STLog -ModuleName GraphTools -Times 1 -ParameterFilter { $Level -eq 'ERROR' }
            Assert-MockCalled Write-STTelemetryEvent -ModuleName GraphTools -Times 1 -ParameterFilter { $Result -eq 'Failure' }
        }
    }

    Context 'Get-GraphAccessToken caching' {
        It 'uses cached token when not expired' {
            $cache = Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName())
            try {
                @{ accessToken='cached'; expiresOn=(Get-Date).AddMinutes(10) } | ConvertTo-Json | Set-Content -Path $cache
                function global:Get-MsalToken {}
                Mock Get-MsalToken { throw 'should not call' } -ModuleName GraphTools
                InModuleScope GraphTools -ScriptBlock { param($c); Get-GraphAccessToken -TenantId 'tid' -ClientId 'cid' -CachePath $c } -ArgumentList $cache | Should -Be 'cached'
                Assert-MockCalled Get-MsalToken -ModuleName GraphTools -Times 0
            } finally {
                Remove-Item function:Get-MsalToken -ErrorAction SilentlyContinue
                Remove-Item $cache -ErrorAction SilentlyContinue
            }
        }

        It 'refreshes token when cache expired' {
            $cache = Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName())
            try {
                @{ accessToken='old'; expiresOn=(Get-Date).AddMinutes(1) } | ConvertTo-Json | Set-Content -Path $cache
                $resp = [pscustomobject]@{ AccessToken='new'; ExpiresOn=(Get-Date).AddHours(1) }
                function global:Get-MsalToken {}
                Mock Get-MsalToken { $resp } -ModuleName GraphTools
                InModuleScope GraphTools -ScriptBlock { param($c); Get-GraphAccessToken -TenantId 'tid' -ClientId 'cid' -CachePath $c } -ArgumentList $cache | Should -Be 'new'
                Assert-MockCalled Get-MsalToken -ModuleName GraphTools -Times 1
                (Get-Content $cache | ConvertFrom-Json).accessToken | Should -Be 'new'
            } finally {
                Remove-Item function:Get-MsalToken -ErrorAction SilentlyContinue
                Remove-Item $cache -ErrorAction SilentlyContinue
            }
        }

        It 'uses USERPROFILE for default cache path' {
            $tempDir = Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName())
            New-Item -ItemType Directory -Path $tempDir | Out-Null
            $oldProfile = $env:USERPROFILE
            try {
                $env:USERPROFILE = $tempDir
                $resp = [pscustomobject]@{ AccessToken='env'; ExpiresOn=(Get-Date).AddHours(1) }
                function global:Get-MsalToken {}
                Mock Get-MsalToken { $resp } -ModuleName GraphTools
                InModuleScope GraphTools -ScriptBlock { Get-GraphAccessToken -TenantId 'tid' -ClientId 'cid' } | Should -Be 'env'
                $expected = Join-Path $tempDir '.graphToken.json'
                Test-Path $expected | Should -Be $true
            } finally {
                Remove-Item function:Get-MsalToken -ErrorAction SilentlyContinue
                if ($null -ne $oldProfile) { $env:USERPROFILE = $oldProfile } else { Remove-Item env:USERPROFILE -ErrorAction SilentlyContinue }
                Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
            }
        }
    }
}
