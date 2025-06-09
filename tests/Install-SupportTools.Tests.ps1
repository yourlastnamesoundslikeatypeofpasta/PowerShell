. $PSScriptRoot/TestHelpers.ps1

Describe 'Install-SupportTools script' {
    BeforeEach {
        function Install-Module {}
        function Import-Module {}
        Mock Install-Module {
            if ($Name -eq 'SharePointTools') { throw 'gallery unavailable' }
        }
        Mock Import-Module {}
    }

    Safe-It 'imports from src when gallery install fails' {
        $warnings = @()
        & $PSScriptRoot/../scripts/Install-SupportTools.ps1 -WarningVariable +warnings -Scope CurrentUser
        $spPath = Join-Path $PSScriptRoot/../src/SharePointTools 'SharePointTools.psd1'
        Assert-MockCalled Import-Module -ParameterFilter { $Name -eq $spPath } -Times 1
        $warnings | Should -Contain "Imported SharePointTools from $spPath"
    }
}
