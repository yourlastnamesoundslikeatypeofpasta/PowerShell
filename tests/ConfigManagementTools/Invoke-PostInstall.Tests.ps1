. $PSScriptRoot/../TestHelpers.ps1
Describe 'Invoke-PostInstall function' {
    Initialize-TestDrive
    BeforeAll {
        Import-Module $PSScriptRoot/../../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../../src/ConfigManagementTools/ConfigManagementTools.psd1 -Force
    }
    Safe-It 'runs Main when script executes' {
        InModuleScope ConfigManagementTools {
            $scriptFile = Join-Path $TestDrive 'PostInstallScript.ps1'
            Set-Content -Path $scriptFile -Value "function Main { $global:MainCalled++ }`nMain"
            $global:MainCalled = 0
            Mock Invoke-ScriptFile { & $scriptFile } -ModuleName ConfigManagementTools
            Invoke-PostInstall | Out-Null
            $global:MainCalled | Should -Be 1
            Remove-Item variable:MainCalled -Scope Global -ErrorAction SilentlyContinue
        }
    }
}
