Describe 'Telemetry Opt-In' {
    BeforeAll {
        Import-Module $PSScriptRoot/../src/SupportTools/SupportTools.psd1 -Force
    }

    It 'does not log telemetry when not opted in' {
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

    It 'logs telemetry when opt-in variable is set' {
        $log = Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName())
        $scriptFile = Join-Path $PSScriptRoot/.. 'scripts/TelemetryTest.ps1'
        Set-Content $scriptFile "Write-Host 'test'"
        try {
            $env:ST_ENABLE_TELEMETRY = '1'
            $env:ST_TELEMETRY_PATH = $log
            InModuleScope SupportTools {
                Invoke-ScriptFile -Name 'TelemetryTest.ps1'
            }
            $entries = Get-Content $log | ForEach-Object { $_ | ConvertFrom-Json }
            ($entries | Where-Object { -not ($_.PSObject.Properties.Name -contains 'Metric') }).Count | Should -Be 1
            $json = $entries | Where-Object { -not ($_.PSObject.Properties.Name -contains 'Metric') }
            $json.Script | Should -Be 'TelemetryTest.ps1'
            $json.Result | Should -Be 'Success'
        } finally {
            Remove-Item $scriptFile -ErrorAction SilentlyContinue
            Remove-Item $log -ErrorAction SilentlyContinue
            Remove-Item env:ST_ENABLE_TELEMETRY -ErrorAction SilentlyContinue
            Remove-Item env:ST_TELEMETRY_PATH -ErrorAction SilentlyContinue
        }
    }
}

Describe 'Telemetry Metrics Summary' {
    BeforeAll {
        Import-Module $PSScriptRoot/../src/Telemetry/Telemetry.psd1 -Force
    }

    It 'aggregates telemetry data' {
        $log = Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName())
        $events = @(
            @{Timestamp='2024-01-01T00:00:00Z'; Script='Test.ps1'; Result='Success'; Duration=2; Category='Test'},
            @{Timestamp='2024-01-01T00:00:01Z'; Script='Test.ps1'; Result='Failure'; Duration=4; Category='Test'}
        ) | ForEach-Object { $_ | ConvertTo-Json -Compress }
        Set-Content -Path $log -Value $events

        try {
            $metrics = Get-STTelemetryMetrics -LogPath $log
            $test = $metrics | Where-Object Script -eq 'Test.ps1'
            $test.Executions | Should -Be 2
            $test.Failures   | Should -Be 1
            $test.AverageSeconds | Should -Be 3
            $test.Category | Should -Be 'Test'
        } finally {
            Remove-Item $log -ErrorAction SilentlyContinue
        }
    }
}

Describe 'Send-STMetric' {
    BeforeAll {
        Import-Module $PSScriptRoot/../src/Telemetry/Telemetry.psd1 -Force
    }

    It 'writes metric entries' {
        $log = Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName())
        try {
            $env:ST_ENABLE_TELEMETRY = '1'
            $env:ST_TELEMETRY_PATH = $log
            Send-STMetric -MetricName 'TestMetric' -Category 'Audit' -Value 1.2
            $json = Get-Content $log | ConvertFrom-Json
            $json.Metric | Should -Be 'TestMetric'
            $json.Category | Should -Be 'Audit'
            $json.Value | Should -Be 1.2
            $json.OperationId | Should -Not -BeNullOrEmpty
        } finally {
            Remove-Item $log -ErrorAction SilentlyContinue
            Remove-Item env:ST_ENABLE_TELEMETRY -ErrorAction SilentlyContinue
            Remove-Item env:ST_TELEMETRY_PATH -ErrorAction SilentlyContinue
        }
    }
}
