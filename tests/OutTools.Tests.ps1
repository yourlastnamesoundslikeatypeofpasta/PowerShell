. $PSScriptRoot/TestHelpers.ps1
Describe 'OutTools Module' {
    Initialize-TestDrive
    BeforeAll {
        Import-Module $PSScriptRoot/../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../src/OutTools/OutTools.psd1 -Force
    }

    Safe-It 'formats banner objects' {
        $obj = [pscustomobject]@{ Module='TestMod'; Version='1.0' }
        { $obj | Out-STBanner } | Should -Not -Throw
    }

    Safe-It 'adds ANSI color when -Color used' {
        Mock Write-STDivider {} -ModuleName Logging
        Mock Write-STStatus {} -ModuleName OutTools
        Mock Write-STLog {} -ModuleName Logging
        Out-STBanner -Info @{ Module='TestMod' } -Color Red
        Assert-MockCalled Write-STDivider -ModuleName Logging -ParameterFilter { $Title.Contains([char]27) } -Times 1
    }

    Safe-It 'prints plain banner by default' {
        Mock Write-STDivider {} -ModuleName Logging
        Mock Write-STStatus {} -ModuleName OutTools
        Mock Write-STLog {} -ModuleName Logging
        Out-STBanner -Info @{ Module='TestMod' }
        Assert-MockCalled Write-STDivider -ModuleName Logging -ParameterFilter { -not $Title.Contains([char]27) } -Times 1
    }
}
