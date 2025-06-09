. $PSScriptRoot/../TestHelpers.ps1

Describe 'Get-ServiceDeskAssetRelationship' {
    BeforeAll {
        Import-Module $PSScriptRoot/../../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../../src/ServiceDeskTools/ServiceDeskTools.psd1 -Force
    }

    It 'passes parameters to Invoke-SDRequest' {
        InModuleScope ServiceDeskTools {
            Mock Invoke-SDRequest { @() }
            Get-ServiceDeskAssetRelationship -AssetId 1 -Type Linked
            Assert-MockCalled Invoke-SDRequest -Times 1 -ParameterFilter {
                $Method -eq 'GET' -and $Path -eq '/asset_relationships.json?asset_id=1&relationship_type=Linked'
            }
        }
    }

    It 'throws when Invoke-SDRequest fails' {
        InModuleScope ServiceDeskTools {
            Mock Invoke-SDRequest { throw 'bad' }
            { Get-ServiceDeskAssetRelationship -AssetId 1 } | Should -Throw
        }
    }
}
