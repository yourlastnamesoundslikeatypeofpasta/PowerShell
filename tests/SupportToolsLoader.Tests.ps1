
. $PSScriptRoot/TestHelpers.ps1

# Determine module manifests at discovery time for -ForEach
$repoRoot = Split-Path $PSScriptRoot -Parent
$moduleFiles = Get-ChildItem -Path (Join-Path $repoRoot 'src') -Recurse -Filter *.psd1 -File | Sort-Object FullName
$moduleNames = $moduleFiles | ForEach-Object { $_.BaseName }

Describe 'SupportToolsLoader Script' {
    Initialize-TestDrive
    BeforeAll {
        $repoRoot = Split-Path $PSScriptRoot -Parent
        $tempRepo = Join-Path $TestDrive 'repo'
        New-Item -ItemType Directory -Path $tempRepo | Out-Null
        Copy-Item -Path (Join-Path $repoRoot 'SupportToolsLoader.ps1') -Destination $tempRepo
        Copy-Item -Recurse -Path (Join-Path $repoRoot 'src') -Destination $tempRepo

        foreach ($n in $moduleNames) { Remove-Module $n -ErrorAction SilentlyContinue }

        Import-Module (Join-Path $tempRepo 'src/Logging/Logging.psd1') -Force
        Import-Module (Join-Path $tempRepo 'src/OutTools/OutTools.psd1') -Force
        Mock Out-STBanner {} -ModuleName OutTools

        Push-Location $tempRepo
        . ./SupportToolsLoader.ps1
        Pop-Location
    }

    It 'imports each module and shows its banner' -ForEach $moduleFiles {
        param($file)
        $name = $file.BaseName
        $module = Get-Module -Name $name
        $module | Should -Not -BeNullOrEmpty
        @($module).Count | Should -Be 1
        Assert-MockCalled Out-STBanner -ModuleName OutTools -Times 1 -ParameterFilter { $Info.Module -eq $name }
    }
}
