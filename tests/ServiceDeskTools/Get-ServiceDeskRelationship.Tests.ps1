. $PSScriptRoot/../TestHelpers.ps1

Describe 'Get-ServiceDeskRelationship' {
    Initialize-TestDrive
    BeforeAll {
        Import-Module $PSScriptRoot/../../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../../src/ServiceDeskTools/ServiceDeskTools.psd1 -Force
    }

    Safe-It 'filters by asset id and type' {
        InModuleScope ServiceDeskTools {
            Mock Invoke-SDRequest { @{ ok = $true } }
            $res = Get-ServiceDeskRelationship -AssetId 5 -Type 'parent'
            Assert-MockCalled Invoke-SDRequest -Times 1 -ParameterFilter {
                $Method -eq 'GET' -and
                $Path -eq '/asset_relationships.json?asset_id=5&relationship_type=parent'
            }
            $res.ok | Should -Be $true
        }
    }

    Safe-It 'passes ChaosMode' {
        InModuleScope ServiceDeskTools {
            Mock Invoke-SDRequest { @{ ok = $true } }
            Get-ServiceDeskRelationship -ChaosMode
            Assert-MockCalled Invoke-SDRequest -Times 1 -ParameterFilter { $ChaosMode -eq $true }
        }
    }

    Safe-It 'throws when Invoke-SDRequest fails' {
        InModuleScope ServiceDeskTools {
            Mock Invoke-SDRequest { throw 'bad' }
            { Get-ServiceDeskRelationship -AssetId 1 } | Should -Throw
        }
    }
}
