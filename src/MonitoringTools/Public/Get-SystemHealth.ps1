function Get-SystemHealth {
    <#
    .SYNOPSIS
        Provides an overview of system health.
    .DESCRIPTION
        Returns CPU usage, disk free space and recent event log summary.
        The combined snapshot is also written to the structured log.
    #>
    [CmdletBinding()]
    param()

    $computer = Get-STComputerName
    $timestamp = (Get-Date).ToString('o')

    $cpu = Get-CPUUsage
    $disks = Get-DiskSpaceInfo
    $events = Get-EventLogSummary

    $result = [pscustomobject]@{
        CpuPercent      = $cpu
        DiskInfo        = $disks
        EventLogSummary = $events
    }

    $json = @{ ComputerName = $computer; Timestamp = $timestamp; Health = $result } | ConvertTo-Json -Compress
    Write-STRichLog -Tool 'Get-SystemHealth' -Status 'queried' -Details $json
    return $result
}
