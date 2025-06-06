@{
    Run = @{ Path = 'tests'; Exit = $true }
    CodeCoverage = @{
        Enabled = $true
        Path = @('src/**/*.ps1','scripts/*.ps1')
        OutputFormat = 'JaCoCo'
        OutputPath = 'coverage.xml'
    }
}
