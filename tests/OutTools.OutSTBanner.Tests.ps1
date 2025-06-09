. $PSScriptRoot/TestHelpers.ps1
Describe 'Out-STBanner function' {
    Initialize-TestDrive
    BeforeAll {
        Import-Module $PSScriptRoot/../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../src/OutTools/OutTools.psd1 -Force
    }

    Safe-It 'invokes Write-STLog when -Log specified' {
        Mock Write-STDivider {} -ModuleName Logging
        Mock Write-STStatus {} -ModuleName OutTools
        Mock Write-STLog {} -ModuleName Logging
        Out-STBanner -Info @{ Module='TestMod' } -Log
        Assert-MockCalled Write-STLog -ModuleName Logging -ParameterFilter { $Message -eq 'TestMod module loaded' } -Times 1
    }

    Safe-It 'returns banner object from the pipeline' {
        $obj = [pscustomobject]@{ Module='TestMod'; Version='1.0' }
        $result = $obj | Out-STBanner
        $result | Should -Be $obj
    }
}
