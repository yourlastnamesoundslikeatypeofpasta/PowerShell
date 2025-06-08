Describe 'ConfigManagementTools Module' {
    BeforeAll {
        Import-Module $PSScriptRoot/../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../src/ConfigManagementTools/ConfigManagementTools.psd1 -Force
    }

    It 'exports Add-UserToGroup' {
        (Get-Command -Module ConfigManagementTools).Name | Should -Contain 'Add-UserToGroup'
    }

    It 'exports Set-ComputerIPAddress' {
        (Get-Command -Module ConfigManagementTools).Name | Should -Contain 'Set-ComputerIPAddress'
    }
}
