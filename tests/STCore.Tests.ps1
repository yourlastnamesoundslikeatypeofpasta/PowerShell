. $PSScriptRoot/TestHelpers.ps1
Describe 'STCore Module' {
    Initialize-TestDrive
    BeforeAll {
        Import-Module $PSScriptRoot/../src/STCore/STCore.psd1 -Force
    }

    Context 'Exported commands' {
        $expected = @(
            'Assert-ParameterNotNull',
            'New-STErrorObject',
            'New-STErrorRecord',
            'Write-STDebug',
            'Test-IsElevated',
            'Get-STConfig',
            'Get-STConfigValue',
            'Invoke-STRequest',
            'Get-STSecret'
        )

        $exported = (Get-Command -Module STCore).Name
        foreach ($cmd in $expected) {
            Safe-It "exports $cmd" {
                $exported | Should -Contain $cmd
            }
        }
    }

    Safe-It 'Show-STCoreBanner reports module version' {
        $banner = Show-STCoreBanner
        $manifest = Import-PowerShellDataFile $PSScriptRoot/../src/STCore/STCore.psd1
        $banner.Module  | Should -Be 'STCore'
        $banner.Version | Should -Be $manifest.ModuleVersion
    }
}
