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

    It 'bypasses chaos when CHAOSTOOLS_ENABLED=0' {
        $script:ran = $false
        try {
            $env:CHAOSTOOLS_ENABLED = '0'
            Invoke-ChaosTest -ScriptBlock { $script:ran = $true } -FailureRate 1 -MaxDelaySeconds 1
            $script:ran | Should -BeTrue
        } finally {
            Remove-Item env:CHAOSTOOLS_ENABLED -ErrorAction SilentlyContinue
        }
    }

    It 'bypasses chaos when CHAOSTOOLS_ENABLED=False' {
        $script:ran = $false
        try {
            $env:CHAOSTOOLS_ENABLED = 'False'
            Invoke-ChaosTest -ScriptBlock { $script:ran = $true } -FailureRate 1 -MaxDelaySeconds 1
            $script:ran | Should -BeTrue
        } finally {
            Remove-Item env:CHAOSTOOLS_ENABLED -ErrorAction SilentlyContinue
        }
    }
}
