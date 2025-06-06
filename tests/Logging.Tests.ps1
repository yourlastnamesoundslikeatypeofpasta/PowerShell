Describe 'Logging Module' {
    BeforeAll {
        Import-Module $PSScriptRoot/../src/Logging/Logging.psd1 -Force
    }

    It 'writes to the path parameter' {
        $temp = [System.IO.Path]::GetTempFileName()
        try {
            Write-STLog -Message 'path test' -Path $temp
            (Get-Content $temp) | Should -Match 'path test'
        } finally {
            Remove-Item $temp -ErrorAction SilentlyContinue
        }
    }

    It 'writes to ST_LOG_PATH when set' {
        $temp = [System.IO.Path]::GetTempFileName()
        try {
            $env:ST_LOG_PATH = $temp
            Write-STLog -Message 'env test'
            (Get-Content $temp) | Should -Match 'env test'
        } finally {
            Remove-Item $temp -ErrorAction SilentlyContinue
            Remove-Item env:ST_LOG_PATH
        }
    }
}
