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

    It 'writes structured log entries when requested' {
        $temp = [System.IO.Path]::GetTempFileName()
        try {
            Write-STLog -Message 'json test' -Path $temp -Structured -Metadata @{action='test'}
            $json = Get-Content $temp | ConvertFrom-Json
            $json.message | Should -Be 'json test'
            $json.level | Should -Be 'INFO'
            $json.action | Should -Be 'test'
        } finally {
            Remove-Item $temp -ErrorAction SilentlyContinue
        }
    }

    It 'writes structured log entries when ST_LOG_STRUCTURED is set' {
        $temp = [System.IO.Path]::GetTempFileName()
        try {
            $env:ST_LOG_STRUCTURED = '1'
            Write-STLog -Message 'env json test' -Path $temp
            $json = Get-Content $temp | ConvertFrom-Json
            $json.message | Should -Be 'env json test'
            $json.level | Should -Be 'INFO'
        } finally {
            Remove-Item $temp -ErrorAction SilentlyContinue
            Remove-Item env:ST_LOG_STRUCTURED -ErrorAction SilentlyContinue
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

    It 'writes rich JSON log entries' {
        $temp = [System.IO.Path]::GetTempFileName()
        try {
            Write-STRichLog -Tool 'TestTool' -Status 'success' -User 'a@b.com' -Duration ([TimeSpan]::FromSeconds(5)) -Details 'ok' -Path $temp
            $json = Get-Content $temp | ConvertFrom-Json
            $json.tool | Should -Be 'TestTool'
            $json.status | Should -Be 'success'
            $json.user | Should -Be 'a@b.com'
            $json.duration | Should -Be '00:00:05'
            $json.details | Should -Contain 'ok'
            $json.timestamp.ToString('o') | Should -Match '^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}'
        } finally {
            Remove-Item $temp -ErrorAction SilentlyContinue
        }
    }

    It 'logs metric entries' {
        $temp = [System.IO.Path]::GetTempFileName()
        try {
            Write-STLog -Metric 'Duration' -Value 2.5 -Path $temp
            $json = Get-Content $temp | ConvertFrom-Json
            $json.metric | Should -Be 'Duration'
            $json.value  | Should -Be 2.5
        } finally {
            Remove-Item $temp -ErrorAction SilentlyContinue
        }
    }
}
