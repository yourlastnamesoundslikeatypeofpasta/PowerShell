@{
    Run = @{ Path = 'tests'; Exit = $true }
    TestResult = @{ Enabled = $true; OutputFormat = 'NUnitXml'; OutputPath = 'TestResults.xml' }
    CodeCoverage = @{
        Enabled = $true
        Path = @('./src','./scripts')
        RecursePaths = $true
        OutputFormat = 'JaCoCo'
        OutputPath = 'coverage.xml'
    }
    TestDrive = @{ Enabled = $false }
}
