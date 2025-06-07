@{
    Run = @{ Path = 'passing-tests'; Exit = $true }
    TestResult = @{ Enabled = $true; OutputFormat = 'NUnitXml'; OutputPath = 'TestResults.xml' }
    CodeCoverage = @{ Enabled = $false }
}
