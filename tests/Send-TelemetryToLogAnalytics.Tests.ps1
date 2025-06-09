. $PSScriptRoot/TestHelpers.ps1
Describe 'Send-TelemetryToLogAnalytics.ps1' {
    Safe-It 'posts JSON telemetry to workspace URI' {
        $log = Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName())
        $event = @{Timestamp='2024-01-01T00:00:00Z'; Script='Test.ps1'; Result='Success'; Duration=1} | ConvertTo-Json -Compress
        Set-Content -Path $log -Value $event
        Mock Invoke-RestMethod {} -Verifiable
        try {
            $env:ST_ENABLE_TELEMETRY = '1'
            & $PSScriptRoot/../scripts/Send-TelemetryToLogAnalytics.ps1 -WorkspaceId 'ws123' -WorkspaceKey 'Zg==' -LogPath $log
            Assert-MockCalled Invoke-RestMethod -ParameterFilter {
                $Method -eq 'Post' -and
                $Uri -eq 'https://ws123.ods.opinsights.azure.com/api/logs?api-version=2016-04-01' -and
                $Body -is [string] -and (($Body | ConvertFrom-Json)[0].Script -eq 'Test.ps1')
            } -Times 1
        } finally {
            Remove-Item $log -ErrorAction SilentlyContinue
            Remove-Item env:ST_ENABLE_TELEMETRY -ErrorAction SilentlyContinue
        }
    }
}
