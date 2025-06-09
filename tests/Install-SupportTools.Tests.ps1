. $PSScriptRoot/TestHelpers.ps1

Describe 'Install-SupportTools script' {
    Initialize-TestDrive
    BeforeEach {
        function Import-Module {}
        Mock Import-Module {}
        Mock Write-STStatus {}
    }

    Safe-It 'imports from src' {
        & $PSScriptRoot/../scripts/Install-SupportTools.ps1 -Scope CurrentUser
        $spPath = Join-Path $PSScriptRoot/../src/SharePointTools 'SharePointTools.psd1'
        Assert-MockCalled Import-Module -ParameterFilter { $Name -eq $spPath } -Times 1
        Assert-MockCalled Write-STStatus -ParameterFilter { $Message -eq "Imported SharePointTools from $spPath" -and $Level -eq 'SUCCESS' } -Times 1
    }
}
