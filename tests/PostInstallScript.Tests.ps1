. $PSScriptRoot/TestHelpers.ps1
Describe 'PostInstallScript Assert-WingetInstalled' {
    BeforeAll {
        . $PSScriptRoot/../scripts/PostInstallScript.ps1
    }

    Context 'winget check' {
        Safe-It 'throws when winget is missing' {
            Mock Get-Command { $null }
            Mock Write-STStatus {}
            { Assert-WingetInstalled } | Should -Throw 'WingetNotFound'
            Assert-MockCalled Write-STStatus -Times 1 -ParameterFilter { $Level -eq 'ERROR' -and $Message -like '*winget*' }
        }

        Safe-It 'logs success when winget exists' {
            Mock Get-Command { @{ Name = 'winget' } }
            Mock Write-STStatus {}
            Assert-WingetInstalled
            Assert-MockCalled Write-STStatus -Times 1 -ParameterFilter { $Level -eq 'SUCCESS' -and $Message -like '*winget*' }
        }
    }
}

Describe 'PostInstallScript OS Guard' {
    Safe-It 'exits when not running on Windows' {
        $scriptPath = Join-Path $PSScriptRoot/../scripts 'PostInstallScript.ps1'
        $output = pwsh -NoProfile -File $scriptPath 2>&1
        $exit = $LASTEXITCODE
        $exit | Should -Be 1
        ($output -join '') | Should -Match 'only run on Windows'
    }
}
