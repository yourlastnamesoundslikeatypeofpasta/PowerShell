. $PSScriptRoot/TestHelpers.ps1
Describe 'Ensure-TestCoverage script' {
    Initialize-TestDrive
    $repoRoot = Resolve-Path "$PSScriptRoot/.."
    $publicDir = Join-Path $repoRoot 'src/SupportTools/Public'
    $tempFile = Join-Path $publicDir 'Temp-TestFunction.ps1'
    BeforeEach {
        Set-Content -Path $tempFile -Value 'function Temp-TestFunction {}'
    }
    AfterEach {
        Remove-Item $tempFile -ErrorAction SilentlyContinue
    }
    Safe-It 'fails when function has no tests' {
        $scriptPath = Join-Path $repoRoot 'scripts/Ensure-TestCoverage.ps1'
        $output = pwsh -NoProfile -File $scriptPath 2>&1
        $exit = $LASTEXITCODE
        $exit | Should -Be 1
        ($output -join '') | Should -Match "No tests found referencing function 'Temp-TestFunction'"
    }
}
