function Get-SystemHealth {
    <#
    .SYNOPSIS
        Returns key system health metrics.
    .DESCRIPTION
        Provides CPU usage, disk space details and memory statistics along with optional event log data.
    .PARAMETER IncludeEvents
        Include latest system event log entries in output.
    #>
    [CmdletBinding()]
    param(
        [switch]$IncludeEvents
    )
    process {
        $cpu = Get-CPUUsage
        $disk = Get-DiskSpace
        $os = Get-CimInstance -ClassName Win32_OperatingSystem
        $memUsedPct = [math]::Round((($os.TotalVisibleMemorySize - $os.FreePhysicalMemory) / $os.TotalVisibleMemorySize) * 100,2)
        $health = [ordered]@{
            CpuPercent    = if ($cpu.PSObject.Properties['Category']) { $null } else { $cpu }
            MemoryPercent = $memUsedPct
            DiskSpace     = $disk
        }
        if ($IncludeEvents) {
            $health.Events = Get-SystemEventLogs -MaxEvents 20
        }
        [pscustomobject]$health
    }
}
