function Get-SystemHealth {
    <#
    .SYNOPSIS
        Provides an overview of system health.
    .DESCRIPTION
        Returns CPU usage, disk free space and recent event log summary.
        Logs a Write-STRichLog event with computer name and timestamp.
    #>
    [CmdletBinding()]
    param()

    $cpu = Get-CPUUsage
    $disks = Get-DiskSpaceInfo
    $events = Get-EventLogSummary
    $computer = if ($env:COMPUTERNAME) { $env:COMPUTERNAME } else { $env:HOSTNAME }
    $time = Get-Date -Format 'o'

    $result = [pscustomobject]@{
        CpuPercent      = $cpu
        DiskInfo        = $disks
        EventLogSummary = $events
    }
    Write-STRichLog -Tool 'Get-SystemHealth' -Status 'success' -Details @("ComputerName=$computer","Timestamp=$time")
    $result
}
