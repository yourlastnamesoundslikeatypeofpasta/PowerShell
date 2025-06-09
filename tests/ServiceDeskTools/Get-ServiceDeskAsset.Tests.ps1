. $PSScriptRoot/../TestHelpers.ps1

Describe 'Get-ServiceDeskAsset' {
    Initialize-TestDrive
    BeforeAll {
        Import-Module $PSScriptRoot/../../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../../src/ServiceDeskTools/ServiceDeskTools.psd1 -Force
    }

    Safe-It 'uses SD_ASSET_BASE_URI when set' {
        InModuleScope ServiceDeskTools {
            $env:SD_ASSET_BASE_URI = 'https://assets.example.com/api/'
            Mock Invoke-SDRequest {}
            Get-ServiceDeskAsset -Id 9
            Assert-MockCalled Invoke-SDRequest -Times 1 -ParameterFilter {
                $Method -eq 'GET' -and $Path -eq '/assets/9.json' -and $BaseUri -eq 'https://assets.example.com/api/'
            }
            Remove-Item env:SD_ASSET_BASE_URI
        }
    }
}
