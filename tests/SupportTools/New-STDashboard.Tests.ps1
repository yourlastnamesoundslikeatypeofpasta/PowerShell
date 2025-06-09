. $PSScriptRoot/../TestHelpers.ps1
Describe 'New-STDashboard function' {
    BeforeAll {
        Import-Module $PSScriptRoot/../../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../../src/Telemetry/Telemetry.psd1 -Force
        Import-Module $PSScriptRoot/../../src/SupportTools/SupportTools.psd1 -Force
    }

    Safe-It 'creates an HTML dashboard with metrics' {
        $log = Join-Path ([IO.Path]::GetTempPath()) ([guid]::NewGuid().ToString() + '.log')
        $tlog = Join-Path ([IO.Path]::GetTempPath()) ([guid]::NewGuid().ToString() + '.jsonl')
        $out = Join-Path ([IO.Path]::GetTempPath()) ([guid]::NewGuid().ToString() + '.html')
        try {
            'sample log' | Set-Content -Path $log
            @{Timestamp='2024-01-01T00:00:00Z'; Script='test.ps1'; Result='Success'; Duration=1} |
                ConvertTo-Json -Compress | Set-Content -Path $tlog
            New-STDashboard -LogPath $log -TelemetryLogPath $tlog -OutputPath $out | Out-Null
            Test-Path $out | Should -Be $true
            $content = Get-Content $out -Raw
            $content | Should -Match '<html>'
            $content | Should -Match '<table'
        } finally {
            Remove-Item $log,$tlog,$out -ErrorAction SilentlyContinue
        }
    }
}
