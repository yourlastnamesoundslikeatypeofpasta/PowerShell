. $PSScriptRoot/TestHelpers.ps1
Describe 'Install-ModuleDependencies script' {
    BeforeEach {
        function Get-Module {}
        function Install-Module {}
        function Read-Host {}
        Mock Get-Module { $null } -Verifiable
        Mock Install-Module {} -Verifiable
        Mock Read-Host { 'Y' }
    }

    Safe-It 'installs all modules from the nuspec when missing' {
        & $PSScriptRoot/../scripts/Install-ModuleDependencies.ps1
        $nuspec = [xml](Get-Content "$PSScriptRoot/../SupportTools.nuspec")
        $modules = $nuspec.package.metadata.dependencies.dependency | ForEach-Object { $_.id }
        foreach ($name in $modules) {
            Assert-MockCalled Install-Module -ParameterFilter { $Name -eq $name } -Times 1
        }
        Assert-MockCalled Get-Module -Times $modules.Count
        Assert-VerifiableMocks
    }

    AfterEach {
        Remove-Item function:Get-Module -ErrorAction SilentlyContinue
        Remove-Item function:Install-Module -ErrorAction SilentlyContinue
        Remove-Item function:Read-Host -ErrorAction SilentlyContinue
    }
}
