Describe 'Update-ModuleDependencies script' {
    BeforeEach {
        function Update-Module {}
        function Get-Module {}
        function Get-AuthenticodeSignature {}
        function Write-STLog {}
        Mock Update-Module {} -Verifiable
        Mock Get-Module { [pscustomobject]@{ Path = 'module.psd1' } } -Verifiable
        Mock Get-AuthenticodeSignature { [pscustomobject]@{ Status = 'Valid'; StatusMessage = 'Valid' } } -Verifiable
        Mock Write-STLog {} -Verifiable
    }

    It 'updates all modules from the nuspec' {
        & $PSScriptRoot/../scripts/Update-ModuleDependencies.ps1
        $nuspec = [xml](Get-Content "$PSScriptRoot/../SupportTools.nuspec")
        $modules = $nuspec.package.metadata.dependencies.dependency | ForEach-Object { $_.id }
        foreach ($name in $modules) {
            Assert-MockCalled Update-Module -ParameterFilter { $Name -eq $name } -Times 1
        }
        Assert-MockCalled Get-AuthenticodeSignature -Times $modules.Count
        Assert-VerifiableMocks
    }
}
