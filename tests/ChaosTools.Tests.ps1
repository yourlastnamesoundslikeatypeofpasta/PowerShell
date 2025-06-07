Describe 'ChaosTools Module' {
    BeforeAll {
        Import-Module $PSScriptRoot/../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../src/ChaosTools/ChaosTools.psd1 -Force
    }

    It 'exports Invoke-ChaosTest' {
        (Get-Command -Module ChaosTools).Name | Should -Contain 'Invoke-ChaosTest'
    }

    It 'executes a script block when failure rate is zero' {
        $script:ran = $false
        Invoke-ChaosTest -ScriptBlock { $script:ran = $true } -FailureRate 0 -MaxDelaySeconds 0
        $script:ran | Should -BeTrue
    }

    It 'throws when failure rate is one' {
        { Invoke-ChaosTest -ScriptBlock { } -FailureRate 1 -MaxDelaySeconds 0 } | Should -Throw
    }
}
