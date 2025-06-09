. $PSScriptRoot/../TestHelpers.ps1

Describe 'Invoke-CompanyPlaceManagement command' {
    Initialize-TestDrive
    BeforeAll {
        Import-Module $PSScriptRoot/../../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../../src/ConfigManagementTools/ConfigManagementTools.psd1 -Force
    }

    Safe-It 'Get returns place objects' {
        InModuleScope ConfigManagementTools {
            Mock Write-STStatus {}
            Mock Get-PlaceV3 { @([pscustomobject]@{ DisplayName='HQ North'; PlaceId='1' }) }
            function Connect-MicrosoftPlaces {}
            $res = Invoke-CompanyPlaceManagement -Action Get -Type Building -DisplayName 'HQ*'
            $res[0].DisplayName | Should -Be 'HQ North'
            Assert-MockCalled Get-PlaceV3 -Times 1 -ParameterFilter { $Type -eq 'Building' }
        }
    }

    Safe-It 'Create adds building and default floor' {
        InModuleScope ConfigManagementTools {
            Mock Write-STStatus {}
            Mock Get-PlaceV3 { @() }
            Mock New-Place { [pscustomobject]@{ DisplayName=$DisplayName; PlaceId='1'; Type=$Type } } -ParameterFilter { $Type -ne 'Floor' }
            Mock New-Place {} -ParameterFilter { $Type -eq 'Floor' -and $Name -eq '1' -and $ParentId -eq '1' } -Verifiable
            function Connect-MicrosoftPlaces {}
            $res = Invoke-CompanyPlaceManagement -Action Create -Type Building -DisplayName 'HQ West' -AutoAddFloor
            $res.DisplayName | Should -Be 'HQ West'
            Assert-MockCalled New-Place -Times 1 -ParameterFilter { $Type -eq 'Floor' -and $Name -eq '1' -and $ParentId -eq '1' }
        }
    }

    Safe-It 'Edit updates existing place' {
        InModuleScope ConfigManagementTools {
            Mock Write-STStatus {}
            Mock Get-PlaceV3 { @([pscustomobject]@{ DisplayName='HQ West'; PlaceId='1' }) }
            Mock Set-PlaceV3 {} -ParameterFilter { $Identity -eq 'HQ West_1' -and $Street -eq '2 Main' } -Verifiable
            function Connect-MicrosoftPlaces {}
            Invoke-CompanyPlaceManagement -Action Edit -Type Building -DisplayName 'HQ West' -Street '2 Main'
            Assert-MockCalled Set-PlaceV3 -Times 1 -ParameterFilter { $Identity -eq 'HQ West_1' -and $Street -eq '2 Main' }
        }
    }
}
