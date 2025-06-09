. $PSScriptRoot/TestHelpers.ps1
Describe 'STCore Error Helpers' {
    BeforeAll {
        Import-Module $PSScriptRoot/../src/STCore/STCore.psd1 -Force
    }

    Safe-It 'New-STErrorRecord returns an ErrorRecord with the provided message' {
        $err = New-STErrorRecord -Message 'oops'
        $err | Should -BeOfType 'System.Management.Automation.ErrorRecord'
        $err.Exception.Message | Should -Be 'oops'
    }

    Safe-It 'New-STErrorObject returns PSCustomObject with Timestamp, Category and Message' {
        $obj = New-STErrorObject -Message 'fail' -Category 'Test'
        $obj | Should -BeOfType 'pscustomobject'
        @('Timestamp', 'Category', 'Message') | ForEach-Object { $obj.PSObject.Properties.Name | Should -Contain $_ }
        $obj.Category | Should -Be 'Test'
        $obj.Message | Should -Be 'fail'
    }
}
