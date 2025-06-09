. $PSScriptRoot/TestHelpers.ps1
Describe 'ScriptLauncher' {
    Safe-It 'executes first script once and loops until quit' {
        if (Get-PSDrive -Name TestDrive -ErrorAction SilentlyContinue) {
            Remove-PSDrive -Name TestDrive -Force
        }
        $tempDir = Join-Path $TestDrive 'scripts'
        New-Item -ItemType Directory -Path $tempDir | Out-Null
        try {
            Copy-Item $PSScriptRoot/../scripts/ScriptLauncher.ps1 $tempDir
            Set-Content -Path (Join-Path $tempDir 'A.ps1') -Value '$global:FirstRun++'
            Set-Content -Path (Join-Path $tempDir 'B.ps1') -Value ''
            Push-Location $tempDir
            $global:FirstRun = 0
            function Write-STDivider {}
            function Write-STStatus {}
            function Write-STClosing {}
            $script:input = 0
            function Read-Host {
                if (++$script:input -eq 1) { '1' } else { 'Q' }
            }
            . ./ScriptLauncher.ps1
            $FirstRun | Should -Be 1
            $script:input | Should -Be 2
        } finally {
            Pop-Location
            Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
            Remove-Item function:Write-STDivider -ErrorAction SilentlyContinue
            Remove-Item function:Write-STStatus -ErrorAction SilentlyContinue
            Remove-Item function:Write-STClosing -ErrorAction SilentlyContinue
            Remove-Item function:Read-Host -ErrorAction SilentlyContinue
        }
    }
}
