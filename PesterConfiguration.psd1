@{
    Run = @{ Path = 'tests'; Exit = $true }
    TestResult = @{ Enabled = $true; OutputFormat = 'NUnitXml'; OutputPath = 'TestResults.xml' }
    CodeCoverage = @{
        Enabled = $true
        Path = @('src/**/*.ps1','scripts/*.ps1')
        OutputFormat = 'JaCoCo'
        OutputPath = 'coverage.xml'
    }
}
