. $PSScriptRoot/TestHelpers.ps1
Describe 'Standalone Scripts' {
    Safe-It 'generates maintenance task XML without registering' {
        $tempDir = Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName())
        New-Item -ItemType Directory -Path $tempDir | Out-Null
        Push-Location $tempDir
        try {
            & $PSScriptRoot/../scripts/Setup-ScheduledMaintenance.ps1
            Test-Path 'WeeklyCleanupTask.xml' | Should -Be $true
            Test-Path 'GroupMaintenanceTask.xml' | Should -Be $true
            Test-Path 'PermissionAuditTask.xml' | Should -Be $true
        }
        finally {
            Pop-Location
            Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    Safe-It 'builds a function dependency graph' {
        $result = & $PSScriptRoot/../scripts/Get-FunctionDependencyGraph.ps1 -Path $PSScriptRoot/../scripts/AddUsersToGroup.ps1 -Format Graphviz
        $result | Should -Match 'digraph'
        $result | Should -Match 'Start-Main'
    }

    Safe-It 'sends telemetry summary via email' {
        $log = Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName())
        $events = @(
            @{Timestamp = '2024-01-01T00:00:00Z'; Script = 'Test.ps1'; Result = 'Success'; Duration = 1 }
        ) | ForEach-Object { $_ | ConvertTo-Json -Compress }
        Set-Content -Path $log -Value $events
        Mock Send-MailMessage {} -Verifiable
        Mock Get-STTelemetryMetrics { @([pscustomobject]@{ Script = 'Test.ps1'; Executions = 1; Successes = 1; Failures = 0; AverageSeconds = 1; LastRun = '2024-01-01T00:00:00Z' }) }
        try {
            $env:ST_ENABLE_TELEMETRY = '1'
            & $PSScriptRoot/../scripts/Send-TelemetrySummary.ps1 -To 'a@b.com' -From 'n@c.com' -SmtpServer 'smtp' -LogPath $log
            Assert-MockCalled Send-MailMessage -ParameterFilter { $To -eq 'a@b.com' -and $From -eq 'n@c.com' -and $SmtpServer -eq 'smtp' -and $Body -match 'Test.ps1' } -Times 1
        }
        finally {
            Remove-Item $log -ErrorAction SilentlyContinue
            Remove-Item env:ST_ENABLE_TELEMETRY -ErrorAction SilentlyContinue
        }
    }

    Safe-It 'loads workspace secrets from the vault' {
        $log = Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName())
        $event = @{Timestamp = '2024-01-01T00:00:00Z'; Script = 'Test.ps1'; Result = 'Success'; Duration = 1 } | ConvertTo-Json -Compress
        Set-Content -Path $log -Value $event
        Mock Get-Secret {
            switch ($Name) {
                'WorkspaceId' { 'id123' }
                'WorkspaceKey' { 'Zg==' }
            }
        }
        Mock Invoke-RestMethod {}
        try {
            $env:ST_ENABLE_TELEMETRY = '1'
            $env:ST_TELEMETRY_PATH = $log
            & $PSScriptRoot/../scripts/Send-TelemetryToLogAnalytics.ps1 -Vault TestVault
            Assert-MockCalled Get-Secret -ParameterFilter { $Name -eq 'WorkspaceId' -and $Vault -eq 'TestVault' } -Times 1
            Assert-MockCalled Get-Secret -ParameterFilter { $Name -eq 'WorkspaceKey' -and $Vault -eq 'TestVault' } -Times 1
        }
        finally {
            Remove-Item $log -ErrorAction SilentlyContinue
            Remove-Item env:ST_ENABLE_TELEMETRY -ErrorAction SilentlyContinue
            Remove-Item env:ST_TELEMETRY_PATH -ErrorAction SilentlyContinue
        }
    }

    Safe-It 'does not fetch provided secrets' {
        $log = Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName())
        $event = @{Timestamp = '2024-01-01T00:00:00Z'; Script = 'Test.ps1'; Result = 'Success'; Duration = 1 } | ConvertTo-Json -Compress
        Set-Content -Path $log -Value $event
        Mock Get-Secret { 'ignored' }
        Mock Invoke-RestMethod {}
        try {
            $env:ST_ENABLE_TELEMETRY = '1'
            $env:ST_TELEMETRY_PATH = $log
            & $PSScriptRoot/../scripts/Send-TelemetryToLogAnalytics.ps1 -WorkspaceId paramId -WorkspaceKey 'Zg==' -Vault TestVault
            Assert-MockCalled Get-Secret -ParameterFilter { $Name -eq 'WorkspaceId' } -Times 0
            Assert-MockCalled Get-Secret -ParameterFilter { $Name -eq 'WorkspaceKey' } -Times 0
        }
        finally {
            Remove-Item $log -ErrorAction SilentlyContinue
            Remove-Item env:ST_ENABLE_TELEMETRY -ErrorAction SilentlyContinue
            Remove-Item env:ST_TELEMETRY_PATH -ErrorAction SilentlyContinue
        }
    }
}
