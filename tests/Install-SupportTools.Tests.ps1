. $PSScriptRoot/TestHelpers.ps1

Describe 'Install-SupportTools script' {
    BeforeEach {
        function Import-Module {}
        Mock Import-Module {}
    }

    Safe-It 'imports from src' {
        $warnings = @()
        & $PSScriptRoot/../scripts/Install-SupportTools.ps1 -WarningVariable +warnings -Scope CurrentUser
        $spPath = Join-Path $PSScriptRoot/../src/SharePointTools 'SharePointTools.psd1'
        Assert-MockCalled Import-Module -ParameterFilter { $Name -eq $spPath } -Times 1
        $warnings | Should -Contain "Imported SharePointTools from $spPath"
    }
}
