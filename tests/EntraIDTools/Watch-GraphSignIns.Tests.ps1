. $PSScriptRoot/../TestHelpers.ps1

Describe 'Watch-GraphSignIns batch output' {
    Initialize-TestDrive
    BeforeAll {
        Import-Module $PSScriptRoot/../../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../../src/Telemetry/Telemetry.psd1 -Force
        Import-Module $PSScriptRoot/../../src/EntraIDTools/EntraIDTools.psd1 -Force
    }

    Safe-It 'emits all sign-ins and stops after count' {
        InModuleScope EntraIDTools {
            $batch1 = 1..5 | ForEach-Object { [pscustomobject]@{ id = $_ } }
            $batch2 = 6..10 | ForEach-Object { [pscustomobject]@{ id = $_ } }
            $calls = 0
            Mock Get-GraphSignInLogs {
                $script:calls++
                if ($script:calls -eq 1) { $batch1 }
                elseif ($script:calls -eq 2) { $batch2 }
                else { @() }
            } -ModuleName EntraIDTools

            $result = Watch-GraphSignIns -TenantId 'tid' -ClientId 'cid' -RequesterEmail 'r@test' -Count 2 -IntervalSeconds 0

            $result.Count | Should -Be 10
            $script:calls | Should -Be 2
        }
    }
}
