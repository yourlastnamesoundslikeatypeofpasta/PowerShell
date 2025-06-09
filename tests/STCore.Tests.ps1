. $PSScriptRoot/TestHelpers.ps1
Describe 'STCore Module' {
    Initialize-TestDrive
    BeforeAll {
        Import-Module $PSScriptRoot/../src/STCore/STCore.psd1 -Force
    }

    Safe-It 'exports Invoke-STRequest' {
        (Get-Command -Module STCore).Name | Should -Contain 'Invoke-STRequest'
    }
}
