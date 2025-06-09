. $PSScriptRoot/../TestHelpers.ps1

Describe 'Get-GraphUserDetails exports' {
    BeforeAll {
        Import-Module $PSScriptRoot/../../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../../src/Telemetry/Telemetry.psd1 -Force
        Import-Module $PSScriptRoot/../../src/EntraIDTools/EntraIDTools.psd1 -Force
        . $PSScriptRoot/../../src/EntraIDTools/Private/Get-GraphAccessToken.ps1
    }

    It 'creates CSV and HTML and records telemetry' {
        Mock Get-GraphAccessToken { 't' } -ModuleName EntraIDTools
        Mock Invoke-STRequest -ModuleName EntraIDTools -ParameterFilter { $Method -eq 'GET' } {
            switch -regex ($Uri) {
                'v1\.0/users/.+\?' { @{ id = '1'; displayName = 'User'; userPrincipalName = 'u@test' } }
                'licenseDetails' { @{ value = @(@{ skuPartNumber = 'A1' }) } }
                'memberOf' { @{ value = @(@{ displayName = 'Group1' }) } }
                'beta/users/.+' { @{ signInActivity = @{ lastSignInDateTime = '2024-01-01T00:00:00Z' } } }
            }
        }
        Mock Write-STLog {} -ModuleName EntraIDTools
        Mock Write-STTelemetryEvent {} -ModuleName EntraIDTools

        $csv = Join-Path ([IO.Path]::GetTempPath()) ([IO.Path]::GetRandomFileName() + '.csv')
        $html = Join-Path ([IO.Path]::GetTempPath()) ([IO.Path]::GetRandomFileName() + '.html')
        try {
            Get-GraphUserDetails -UserPrincipalName 'u@test' -TenantId 'tid' -ClientId 'cid' -CsvPath $csv -HtmlPath $html | Out-Null
            Test-Path $csv | Should -Be $true
            (Get-Content $csv | Select-Object -First 1) | Should -Match 'UserPrincipalName'
            Test-Path $html | Should -Be $true
            (Get-Content $html -Raw) | Should -Match 'User Details'
            Assert-MockCalled Write-STTelemetryEvent -ModuleName EntraIDTools -Times 1
        }
        finally {
            Remove-Item $csv -ErrorAction SilentlyContinue
            Remove-Item $html -ErrorAction SilentlyContinue
        }
    }
}
