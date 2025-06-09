. $PSScriptRoot/../TestHelpers.ps1

Describe 'Test-SPToolsSiteAdmin function' {
    BeforeAll {
        Import-Module $PSScriptRoot/../../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../../src/Telemetry/Telemetry.psd1 -Force
        Import-Module $PSScriptRoot/../../src/SharePointTools/SharePointTools.psd1 -Force
    }

    Safe-It 'returns status object when site reachable and user is admin' {
        InModuleScope SharePointTools {
            Mock Invoke-WebRequest { [pscustomobject]@{ StatusCode = 200 } }
            Mock Connect-SPToolsOnline {}
            Mock Invoke-PnPSPRestMethod { @{ IsSiteAdmin = $true } }
            Mock Disconnect-PnPOnline {}
            Mock Write-STTelemetryEvent {}
            Mock Write-STLog {}
            $r = Test-SPToolsSiteAdmin -SiteUrl 'https://contoso' -ClientId 'id' -TenantId 'tid' -CertPath 'cert'
            $r.StatusCode | Should -Be 200
            $r.IsAdmin | Should -BeTrue
        }
    }

    Safe-It 'throws when site cannot be reached' {
        InModuleScope SharePointTools {
            Mock Invoke-WebRequest { throw 'fail' }
            { Test-SPToolsSiteAdmin -SiteUrl 'https://bad' } | Should -Throw
        }
    }

    Safe-It 'throws when admin rights check fails' {
        InModuleScope SharePointTools {
            Mock Invoke-WebRequest { [pscustomobject]@{ StatusCode = 200 } }
            Mock Connect-SPToolsOnline { throw 'err' }
            Mock Disconnect-PnPOnline {}
            { Test-SPToolsSiteAdmin -SiteUrl 'https://contoso' } | Should -Throw
        }
    }
}
