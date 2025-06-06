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

    It 'writes to the default log path' {
        $tempDir = Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName())
        New-Item -ItemType Directory -Path $tempDir | Out-Null
        $oldHome = $env:HOME
        $oldUser = $env:USERPROFILE
        try {
            $env:HOME = $tempDir
            $env:USERPROFILE = ''
            Remove-Item env:ST_LOG_PATH -ErrorAction SilentlyContinue
            Write-STLog -Message 'default test'
            $expected = Join-Path $tempDir 'SupportToolsLogs/supporttools.log'
            (Get-Content $expected) | Should -Match 'default test'
        } finally {
            if ($null -ne $oldHome) { $env:HOME = $oldHome } else { Remove-Item env:HOME -ErrorAction SilentlyContinue }
            if ($null -ne $oldUser) { $env:USERPROFILE = $oldUser } else { Remove-Item env:USERPROFILE -ErrorAction SilentlyContinue }
            Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    It 'creates the log directory when needed' {
        $tempDir = Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName())
        $logPath = Join-Path $tempDir 'nested/log.txt'
        try {
            Write-STLog -Message 'dir create test' -Path $logPath
            Test-Path $logPath | Should -Be $true
        } finally {
            Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    It 'includes timestamp and level in the output' {
        $temp = [System.IO.Path]::GetTempFileName()
        try {
            Write-STLog -Message 'format test' -Level WARN -Path $temp
            $content = Get-Content $temp
            $content | Should -Match '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} \[WARN\] format test$'
        } finally {
            Remove-Item $temp -ErrorAction SilentlyContinue
        }
    }

    It 'throws on invalid log level' {
        $temp = [System.IO.Path]::GetTempFileName()
        try {
            { Write-STLog -Message 'bad level' -Level INVALID -Path $temp } | Should -Throw
        } finally {
            Remove-Item $temp -ErrorAction SilentlyContinue
        }
    }

    It 'masks sensitive data in status messages' {
        $temp = [System.IO.Path]::GetTempFileName()
        try {
            $env:ST_LOG_PATH = $temp
            Write-STStatus -Message 'Token: secret123' -MaskSensitive -Log
            (Get-Content $temp) | Should -Match 'Token: \*\*\*\*'
        } finally {
            Remove-Item $temp -ErrorAction SilentlyContinue
            Remove-Item env:ST_LOG_PATH
        }
    }
}
