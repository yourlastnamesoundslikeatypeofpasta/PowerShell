. $PSScriptRoot/../TestHelpers.ps1
Describe 'Export-ITReport function' {
    BeforeAll {
        Import-Module $PSScriptRoot/../../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../../src/SupportTools/SupportTools.psd1 -Force
    }

    Safe-It 'creates a CSV report' {
        $path = Join-Path ([IO.Path]::GetTempPath()) ([guid]::NewGuid().ToString() + '.csv')
        try {
            @([pscustomobject]@{A=1;B=2}) | Export-ITReport -Format CSV -OutputPath $path
            Test-Path $path | Should -Be $true
            (Get-Content $path | Select-Object -First 1) | Should -Match 'A,B'
        } finally {
            Remove-Item $path -ErrorAction SilentlyContinue
        }
    }

    Safe-It 'returns generated path when OutputPath not provided' {
        $path = @([pscustomobject]@{A=1}) | Export-ITReport -Format JSON
        try {
            Test-Path $path | Should -Be $true
            $path | Should -Match '\.json$'
        } finally {
            Remove-Item $path -ErrorAction SilentlyContinue
        }
    }
}
