<#+
.SYNOPSIS
    Collect basic performance metrics.
.DESCRIPTION
    Uses Measure-STCommand to capture CPU and memory usage for a sample workload.
#>
param()

Import-Module (Join-Path $PSScriptRoot '..' 'src/Logging/Logging.psd1') -Force -ErrorAction SilentlyContinue
Import-Module (Join-Path $PSScriptRoot '..' 'src/PerformanceTools/PerformanceTools.psd1') -Force -ErrorAction SilentlyContinue

Write-STStatus -Message 'Running performance audit...' -Level INFO -Log
$metrics = Measure-STCommand { Get-Process | Out-Null } -Quiet
Write-STStatus -Message 'Performance audit complete.' -Level SUCCESS -Log
return $metrics
