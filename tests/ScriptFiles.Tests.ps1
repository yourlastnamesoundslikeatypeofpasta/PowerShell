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
        } finally {
            Pop-Location
            Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    Safe-It 'builds a function dependency graph' {
        $result = & $PSScriptRoot/../scripts/Get-FunctionDependencyGraph.ps1 -Path $PSScriptRoot/../scripts/AddUsersToGroup.ps1 -Format Graphviz
        $result | Should -Match 'digraph'
        $result | Should -Match 'Start-Main'
    }

    Safe-It 'includes Vault parameter' {
        (Get-Command $PSScriptRoot/../scripts/Send-TelemetryToLogAnalytics.ps1).Parameters.Keys | Should -Contain 'Vault'
    }

    It 'loads workspace secrets from vault when not provided' {
        $log = Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName())
        '{"MetricName":"Test","Script":"Foo","Timestamp":"2024-01-01T00:00:00Z"}' | Out-File $log
        $env:ST_ENABLE_TELEMETRY = '1'
        $env:ST_TELEMETRY_PATH = $log
        Remove-Item env:ST_WORKSPACE_ID -ErrorAction SilentlyContinue
        Remove-Item env:ST_WORKSPACE_KEY -ErrorAction SilentlyContinue
        Mock Get-Secret {
            switch ($Name) {
                'ST_WORKSPACE_ID' { 'id' }
                'ST_WORKSPACE_KEY' { 'key' }
            }
        }
        Mock Invoke-RestMethod {}
        & $PSScriptRoot/../scripts/Send-TelemetryToLogAnalytics.ps1 -Vault TestVault
        Assert-MockCalled Get-Secret -ParameterFilter { $Name -eq 'ST_WORKSPACE_ID' -and $Vault -eq 'TestVault' } -Times 1
        Assert-MockCalled Get-Secret -ParameterFilter { $Name -eq 'ST_WORKSPACE_KEY' -and $Vault -eq 'TestVault' } -Times 1
        Remove-Item $log -ErrorAction SilentlyContinue
        Remove-Item env:ST_ENABLE_TELEMETRY -ErrorAction SilentlyContinue
        Remove-Item env:ST_TELEMETRY_PATH -ErrorAction SilentlyContinue
        Remove-Item env:ST_WORKSPACE_ID -ErrorAction SilentlyContinue
        Remove-Item env:ST_WORKSPACE_KEY -ErrorAction SilentlyContinue
    }
}
