Describe 'STCore Module' {
    BeforeAll {
        Import-Module $PSScriptRoot/../src/STCore/STCore.psd1 -Force
    }

    It 'exports Invoke-STRequest' {
        (Get-Command -Module STCore).Name | Should -Contain 'Invoke-STRequest'
    }
}
