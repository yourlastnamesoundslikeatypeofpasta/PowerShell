. $PSScriptRoot/../TestHelpers.ps1
Describe 'Invoke-PerformanceAudit.ps1 script' {
    BeforeAll {
        $ScriptPath = Join-Path $PSScriptRoot/../.. 'src/PerformanceTools/Invoke-PerformanceAudit.ps1'
        Import-Module $PSScriptRoot/../../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../../src/Telemetry/Telemetry.psd1 -Force
        Import-Module $PSScriptRoot/../../src/ServiceDeskTools/ServiceDeskTools.psd1 -Force
    }
    BeforeEach {
        function Get-Counter { param([string]$CounterPath,[int]$SampleInterval,[int]$MaxSamples)
            [pscustomobject]@{ CounterSamples = @(1..$MaxSamples | ForEach-Object { [pscustomobject]@{ CookedValue = 10 } }) }
        }
        function Get-CimInstance { [pscustomobject]@{ TotalVisibleMemorySize = 100; FreePhysicalMemory = 50 } }
        function Get-Uptime { New-TimeSpan -Minutes 5 }
        Mock Write-STLog {}
        Mock Write-STStatus {}
        Mock Send-STMetric {}
        Mock Write-STTelemetryEvent {}
        function Write-STBlock {}
        Mock New-SDTicket { @{ id = 1 } }
    }

    Safe-It 'logs performance metrics' {
        & $ScriptPath -CpuThreshold 100 -MemoryThreshold 100 -DiskThreshold 100 -NetworkThreshold 100 -RequesterEmail 'user@example.com' | Out-Null
        Assert-MockCalled Write-STLog -ParameterFilter { $Metric -eq 'CPUPercent' } -Times 1
        Assert-MockCalled Write-STLog -ParameterFilter { $Metric -eq 'MemoryPercent' } -Times 1
        Assert-MockCalled Write-STLog -ParameterFilter { $Metric -eq 'DiskPercent' } -Times 1
        Assert-MockCalled Write-STLog -ParameterFilter { $Metric -eq 'NetworkMbps' } -Times 1
        Assert-MockCalled Send-STMetric -ParameterFilter { $MetricName -eq 'PerformanceAuditDuration' } -Times 1
    }

    Safe-It 'creates a ticket when thresholds exceeded' {
        & $ScriptPath -CpuThreshold 0 -MemoryThreshold 0 -DiskThreshold 0 -NetworkThreshold 0 -CreateTicket -RequesterEmail 'user@example.com' | Out-Null
        Assert-MockCalled Write-STStatus -ParameterFilter { $Message -eq 'Performance thresholds exceeded:' } -Times 1
        Assert-MockCalled New-SDTicket -Times 1
    }
}
