@{
    Run = @{ Path = 'tests'; Exit = $true; ShouldStop = 'OnRunError' }
    TestResult = @{ Enabled = $true; OutputFormat = 'NUnitXml'; OutputPath = 'TestOutput/TestResults.xml' }
    CodeCoverage = @{
        Enabled = $true
        Path = @('./src','./scripts')
        RecursePaths = $true
        OutputFormat = 'JaCoCo'
        OutputPath = 'TestOutput/coverage.xml'
        CoveragePercentTarget = 80
    }
    TestDrive = @{ Enabled = $true }
}
