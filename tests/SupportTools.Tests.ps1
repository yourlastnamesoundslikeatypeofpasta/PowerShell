Describe 'SupportTools Module' {
    It 'Exports expected command' {
        Import-Module $PSScriptRoot/../src/SupportTools/SupportTools.psd1 -Force
        (Get-Command Get-CommonSystemInfo).Name | Should -Be 'Get-CommonSystemInfo'
    }
}
