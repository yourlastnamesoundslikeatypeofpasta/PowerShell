<#+
.SYNOPSIS
    Collect basic performance metrics.
.DESCRIPTION
    Uses Measure-STCommand to capture CPU and memory usage for a sample workload.
#>
param()

Import-Module (Join-Path $PSScriptRoot '..' 'src/Logging/Logging.psd1') -ErrorAction SilentlyContinue
Import-Module (Join-Path $PSScriptRoot '..' 'src/PerformanceTools/PerformanceTools.psd1') -ErrorAction SilentlyContinue

Write-STStatus 'Running performance audit...' -Level INFO -Log
$metrics = Measure-STCommand { Get-Process | Out-Null } -Quiet
Write-STStatus 'Performance audit complete.' -Level SUCCESS -Log
return $metrics
