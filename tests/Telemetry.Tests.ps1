. $PSScriptRoot/TestHelpers.ps1
Describe 'Telemetry Opt-In' {
    BeforeAll {
        Import-Module $PSScriptRoot/../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../src/Telemetry/Telemetry.psd1 -Force
        Import-Module $PSScriptRoot/../src/SharePointTools/SharePointTools.psd1 -Force
        Import-Module $PSScriptRoot/../src/ServiceDeskTools/ServiceDeskTools.psd1 -Force
        Import-Module $PSScriptRoot/../src/SupportTools/SupportTools.psd1 -Force
    }

    Safe-It 'does not log telemetry when not opted in' {
        $log = Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName())
        $scriptFile = Join-Path $PSScriptRoot/.. 'scripts/TelemetryTest.ps1'
        Set-Content $scriptFile "Write-Host 'test'"
        try {
            Remove-Item env:ST_ENABLE_TELEMETRY -ErrorAction SilentlyContinue
            $env:ST_TELEMETRY_PATH = $log
            InModuleScope SupportTools {
                Invoke-ScriptFile -Name 'TelemetryTest.ps1'
            }
            Test-Path $log | Should -Be $false
        } finally {
            Remove-Item $scriptFile -ErrorAction SilentlyContinue
            Remove-Item env:ST_TELEMETRY_PATH -ErrorAction SilentlyContinue
        }
    }

    Safe-It 'logs telemetry when opt-in variable is set' {
        $log = Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName())
        $scriptFile = Join-Path $PSScriptRoot/.. 'scripts/TelemetryTest.ps1'
        Set-Content $scriptFile "Write-Host 'test'"
        try {
            $env:ST_ENABLE_TELEMETRY = '1'
            $env:ST_TELEMETRY_PATH = $log
            InModuleScope SupportTools {
                Invoke-ScriptFile -Name 'TelemetryTest.ps1'
            }
            (Get-Content $log | Measure-Object -Line).Lines | Should -Be 2
            $entries = Get-Content $log | ForEach-Object { $_ | ConvertFrom-Json }
            $telemetry = $entries | Where-Object Script
            $metric = $entries | Where-Object MetricName
            $telemetry.Script | Should -Be 'TelemetryTest.ps1'
            $telemetry.Result | Should -Be 'Success'
            $metric.MetricName | Should -Be 'ExecutionSeconds'
        } finally {
            Remove-Item $scriptFile -ErrorAction SilentlyContinue
            Remove-Item $log -ErrorAction SilentlyContinue
            Remove-Item env:ST_ENABLE_TELEMETRY -ErrorAction SilentlyContinue
            Remove-Item env:ST_TELEMETRY_PATH -ErrorAction SilentlyContinue
        }
    }

    Safe-It 'Write-STTelemetryEvent does nothing when telemetry disabled' {
        $log = Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName())
        try {
            Remove-Item env:ST_ENABLE_TELEMETRY -ErrorAction SilentlyContinue
            $env:ST_TELEMETRY_PATH = $log
            Write-STTelemetryEvent -ScriptName 'Foo.ps1' -Result 'Success' -Duration ([timespan]::FromSeconds(1))
            Test-Path $log | Should -Be $false
        } finally {
            Remove-Item env:ST_TELEMETRY_PATH -ErrorAction SilentlyContinue
        }
    }

    Safe-It 'Write-STTelemetryEvent logs a json entry when enabled' {
        $log = Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName())
        try {
            $env:ST_ENABLE_TELEMETRY = '1'
            $env:ST_TELEMETRY_PATH = $log
            Write-STTelemetryEvent -ScriptName 'Foo.ps1' -Result 'Failure' -Duration ([timespan]::FromSeconds(2))
            (Get-Content $log | Measure-Object -Line).Lines | Should -Be 1
            $json = Get-Content $log | ConvertFrom-Json
            $json.Script | Should -Be 'Foo.ps1'
            $json.Result | Should -Be 'Failure'
        } finally {
            Remove-Item $log -ErrorAction SilentlyContinue
            Remove-Item env:ST_ENABLE_TELEMETRY -ErrorAction SilentlyContinue
            Remove-Item env:ST_TELEMETRY_PATH -ErrorAction SilentlyContinue
        }
    }
}

Describe 'Telemetry Metrics Summary' {
    BeforeAll {
        Import-Module $PSScriptRoot/../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../src/Telemetry/Telemetry.psd1 -Force
    }

    Safe-It 'aggregates telemetry data' {
        $log = Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName())
        $events = @(
            @{Timestamp='2024-01-01T00:00:00Z'; Script='Test.ps1'; Result='Success'; Duration=2},
            @{Timestamp='2024-01-01T00:00:01Z'; Script='Test.ps1'; Result='Failure'; Duration=4}
        ) | ForEach-Object { $_ | ConvertTo-Json -Compress }
        Set-Content -Path $log -Value $events

        try {
            $metrics = Get-STTelemetryMetrics -LogPath $log
            $test = $metrics | Where-Object Script -eq 'Test.ps1'
            $test.Executions | Should -Be 2
            $test.Failures   | Should -Be 1
            $test.AverageSeconds | Should -Be 3
        } finally {
            Remove-Item $log -ErrorAction SilentlyContinue
        }
    }

    Safe-It 'records metrics using Send-STMetric' {
        $log = Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName())
        try {
            $env:ST_ENABLE_TELEMETRY = '1'
            $env:ST_TELEMETRY_PATH = $log
            Send-STMetric -MetricName 'TestMetric' -Category 'Audit' -Value 1.5
            (Get-Content $log | Measure-Object -Line).Lines | Should -Be 1
            $json = Get-Content $log | ConvertFrom-Json
            $json.MetricName | Should -Be 'TestMetric'
            $json.Category | Should -Be 'Audit'
            $json.Value | Should -Be 1.5
        } finally {
            Remove-Item $log -ErrorAction SilentlyContinue
            Remove-Item env:ST_ENABLE_TELEMETRY -ErrorAction SilentlyContinue
            Remove-Item env:ST_TELEMETRY_PATH -ErrorAction SilentlyContinue
        }
    }

    Safe-It 'writes metrics to a sqlite database' {
        $log = Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName())
        $db  = Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName())
        $events = @(
            @{Timestamp='2024-01-01T00:00:00Z'; Script='Test.ps1'; Result='Success'; Duration=1},
            @{Timestamp='2024-01-01T00:00:01Z'; Script='Test.ps1'; Result='Failure'; Duration=3}
        ) | ForEach-Object { $_ | ConvertTo-Json -Compress }
        Set-Content -Path $log -Value $events

        try {
            Mock sqlite3 { param($path,$sql) Add-Content -Path $path -Value $sql } -ModuleName Telemetry

            Get-STTelemetryMetrics -LogPath $log -SqlitePath $db | Out-Null
            $content = Get-Content $db -Raw
            $content | Should -Match 'CREATE TABLE'
            ($content -split "`n" | Where-Object { $_ -match 'INSERT OR REPLACE' }).Count | Should -Be 1

            $events += (@{Timestamp='2024-01-02T00:00:00Z'; Script='Test.ps1'; Result='Success'; Duration=2} | ConvertTo-Json -Compress)
            Set-Content -Path $log -Value $events
            Get-STTelemetryMetrics -LogPath $log -SqlitePath $db | Out-Null
            $content = Get-Content $db -Raw
            ($content -split "`n" | Where-Object { $_ -match 'INSERT OR REPLACE' }).Count | Should -Be 2
        } finally {
            Remove-Item $log -ErrorAction SilentlyContinue
            Remove-Item $db -ErrorAction SilentlyContinue
        }
    }
}

Describe 'Telemetry Banner' {
    BeforeAll {
        Import-Module $PSScriptRoot/../src/Telemetry/Telemetry.psd1 -Force
    }

    Safe-It 'returns module and version data' {
        InModuleScope Telemetry {
            $expected = (Import-PowerShellDataFile "$PSScriptRoot/../src/Telemetry/Telemetry.psd1").ModuleVersion
            $banner = Show-TelemetryBanner
            $banner.Module  | Should -Be 'Telemetry'
            $banner.Version | Should -Be $expected
        }
    }
}
