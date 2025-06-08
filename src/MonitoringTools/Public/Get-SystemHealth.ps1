function Get-SystemHealth {
    <#
    .SYNOPSIS
        Provides an overview of system health.
    .DESCRIPTION
        Returns CPU usage, disk free space and recent event log summary.
    #>
    [CmdletBinding()]
    param()

    $cpu = Get-CPUUsage
    $disks = Get-DiskSpaceInfo
    $events = Get-EventLogSummary

    [pscustomobject]@{
        CpuPercent      = $cpu
        DiskInfo        = $disks
        EventLogSummary = $events
    }
}
