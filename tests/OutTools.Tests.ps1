Describe 'OutTools Module' {
    BeforeAll {
        Import-Module $PSScriptRoot/../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../src/OutTools/OutTools.psd1 -Force
    }

    It 'formats banner objects' {
        $obj = [pscustomobject]@{ Module='TestMod'; Version='1.0' }
        { $obj | Out-STBanner } | Should -Not -Throw
    }
}
