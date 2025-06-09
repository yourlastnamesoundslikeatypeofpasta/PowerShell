. $PSScriptRoot/TestHelpers.ps1
Describe 'Out-STStatus function' {
    Initialize-TestDrive
    BeforeAll {
        Import-Module $PSScriptRoot/../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../src/OutTools/OutTools.psd1 -Force
    }

    Safe-It 'forwards parameters to Write-STStatus' {
        Mock Write-STStatus {} -ModuleName OutTools
        Out-STStatus -Message 'hello' -Level WARN
        Assert-MockCalled Write-STStatus -ModuleName OutTools -ParameterFilter { $Message -eq 'hello' -and $Level -eq 'WARN' } -Times 1
    }

    Safe-It 'accepts pipeline input for Message' {
        Mock Write-STStatus {} -ModuleName OutTools
        'hello' | Out-STStatus -Level INFO
        Assert-MockCalled Write-STStatus -ModuleName OutTools -ParameterFilter { $Message -eq 'hello' -and $Level -eq 'INFO' } -Times 1
    }

    Safe-It 'invokes Write-STLog when -Log specified' {
        Mock Write-STStatus {} -ModuleName OutTools
        Mock Write-STLog {} -ModuleName Logging
        Out-STStatus -Message 'log me' -Level INFO -Log
        Assert-MockCalled Write-STStatus -ModuleName OutTools -ParameterFilter { $Message -eq 'log me' -and $Level -eq 'INFO' -and $Log } -Times 1
        Assert-MockCalled Write-STLog -ModuleName Logging -ParameterFilter { $Message -eq '[*] log me' } -Times 1
    }

    Safe-It 'does not invoke Write-STLog when -Log omitted' {
        Mock Write-STStatus {} -ModuleName OutTools
        Mock Write-STLog {} -ModuleName Logging
        Out-STStatus -Message 'skip log' -Level INFO
        Assert-MockCalled Write-STStatus -ModuleName OutTools -ParameterFilter { $Message -eq 'skip log' -and $Level -eq 'INFO' -and -not $Log } -Times 1
        Assert-MockCalled Write-STLog -ModuleName Logging -Times 0
    }
}
