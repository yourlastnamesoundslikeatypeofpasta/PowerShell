<#
.SYNOPSIS
    Perform a system performance audit and optionally create a Service Desk ticket.
.DESCRIPTION
    Collects key performance metrics including CPU, memory, disk I/O, network usage and system uptime.
    Results are logged via the Logging module and a telemetry event is sent via the Telemetry module.
    When -CreateTicket is specified, ServiceDeskTools is used to open an incident if any thresholds are exceeded.
.PARAMETER CpuThreshold
    CPU usage percentage that triggers an alert. Default 80.
.PARAMETER MemoryThreshold
    Memory usage percentage that triggers an alert. Default 80.
.PARAMETER DiskThreshold
    Disk utilisation percentage that triggers an alert. Default 80.
.PARAMETER NetworkThreshold
    Network throughput in Mbps that triggers an alert. Default 100.
.PARAMETER CreateTicket
    Create a Service Desk ticket when an alert is generated.
.PARAMETER RequesterEmail
    Requester email address for the ticket.
.PARAMETER TranscriptPath
    Optional transcript log path.
.EXAMPLE
    ./Invoke-PerformanceAudit.ps1 -CreateTicket -RequesterEmail 'admin@example.com'
#>
param(
    [int]$CpuThreshold = 80,
    [int]$MemoryThreshold = 80,
    [int]$DiskThreshold = 80,
    [int]$NetworkThreshold = 100,
    [switch]$CreateTicket,
    [string]$RequesterEmail,
    [string]$TranscriptPath
)

$moduleRoot = Join-Path $PSScriptRoot '..'
Import-Module (Join-Path $moduleRoot 'STCore/STCore.psd1') -ErrorAction SilentlyContinue
Import-Module (Join-Path $moduleRoot 'Logging/Logging.psd1') -ErrorAction SilentlyContinue
Import-Module (Join-Path $moduleRoot 'Telemetry/Telemetry.psd1') -ErrorAction SilentlyContinue
if ($CreateTicket) {
    Import-Module (Join-Path $moduleRoot 'ServiceDeskTools/ServiceDeskTools.psd1') -ErrorAction SilentlyContinue
}

if ($TranscriptPath) {
    Start-Transcript -Path $TranscriptPath -Append | Out-Null
}

$scriptName = Split-Path -Leaf $PSCommandPath
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
$result = 'Success'
$alerts = @()

try {
    Write-STDivider 'PERFORMANCE AUDIT' -Style heavy

    # CPU usage
    $cpuSamples = Get-Counter '\Processor(_Total)\% Processor Time' -SampleInterval 1 -MaxSamples 3
    $cpuUsage = [math]::Round(($cpuSamples.CounterSamples | Measure-Object -Property CookedValue -Average).Average,2)
    Write-STLog -Metric 'CPUPercent' -Value $cpuUsage -Structured
    Send-STMetric -MetricName 'CPUPercent' -Category 'Audit' -Value $cpuUsage

    # Memory usage
    $os = Get-CimInstance -ClassName Win32_OperatingSystem
    $memUsedPct = [math]::Round((($os.TotalVisibleMemorySize - $os.FreePhysicalMemory) / $os.TotalVisibleMemorySize) * 100,2)
    Write-STLog -Metric 'MemoryPercent' -Value $memUsedPct -Structured
    Send-STMetric -MetricName 'MemoryPercent' -Category 'Audit' -Value $memUsedPct

    # Disk utilisation
    $diskSamples = Get-Counter '\PhysicalDisk(_Total)\% Disk Time' -SampleInterval 1 -MaxSamples 3
    $diskUsage = [math]::Round(($diskSamples.CounterSamples | Measure-Object -Property CookedValue -Average).Average,2)
    Write-STLog -Metric 'DiskPercent' -Value $diskUsage -Structured
    Send-STMetric -MetricName 'DiskPercent' -Category 'Audit' -Value $diskUsage

    # Network usage (Mbps)
    $netSamples = Get-Counter '\Network Interface(*)\Bytes Total/sec' -SampleInterval 1 -MaxSamples 3
    $netBytes = ($netSamples.CounterSamples | Measure-Object -Property CookedValue -Sum).Sum / $netSamples.CounterSamples.Count
    $netMbps = [math]::Round(($netBytes * 8) / 1MB,2)
    Write-STLog -Metric 'NetworkMbps' -Value $netMbps -Structured
    Send-STMetric -MetricName 'NetworkMbps' -Category 'Audit' -Value $netMbps

    # Uptime
    $uptime = (Get-Uptime).ToString()
    Write-STLog -Message "Uptime: $uptime" -Structured

    $report = [pscustomobject]@{
        CpuPercent     = $cpuUsage
        MemoryPercent  = $memUsedPct
        DiskPercent    = $diskUsage
        NetworkMbps    = $netMbps
        Uptime         = $uptime
    }

    Write-STBlock $report

    if ($cpuUsage -gt $CpuThreshold)    { $alerts += "CPU usage $cpuUsage% > $CpuThreshold%" }
    if ($memUsedPct -gt $MemoryThreshold) { $alerts += "Memory usage $memUsedPct% > $MemoryThreshold%" }
    if ($diskUsage -gt $DiskThreshold)  { $alerts += "Disk usage $diskUsage% > $DiskThreshold%" }
    if ($netMbps -gt $NetworkThreshold) { $alerts += "Network usage $netMbps Mbps > $NetworkThreshold Mbps" }

    if ($alerts.Count -gt 0) {
        Write-STStatus 'Performance thresholds exceeded:' -Level WARN -Log
        foreach ($alert in $alerts) { Write-STStatus $alert -Level WARN -Log }
    } else {
        Write-STStatus 'All metrics within thresholds.' -Level SUCCESS -Log
    }

    if ($CreateTicket -and $alerts.Count -gt 0) {
        if (-not $RequesterEmail) { throw 'RequesterEmail is required when creating a ticket.' }
        $subject = "Performance alert on $env:COMPUTERNAME"
        $desc = $alerts -join '\n'
        $ticket = New-SDTicket -Subject $subject -Description $desc -RequesterEmail $RequesterEmail
        Write-STStatus "Created Service Desk ticket ID $($ticket.id)" -Level SUCCESS -Log
        $report | Add-Member -NotePropertyName TicketId -NotePropertyValue $ticket.id -Force
    }

    $report
} catch {
    Write-STStatus "Audit failed: $_" -Level ERROR -Log
    $result = 'Failure'
    throw
} finally {
    $stopwatch.Stop()
    $opId = [guid]::NewGuid().ToString()
    Write-STTelemetryEvent -ScriptName $scriptName -Result $result -Duration $stopwatch.Elapsed -Category 'Audit' -OperationId $opId
    Send-STMetric -MetricName 'PerformanceAuditDuration' -Category 'Audit' -Value $stopwatch.Elapsed.TotalSeconds -Details @{ Result = $result; OperationId = $opId }
    if ($TranscriptPath) { Stop-Transcript | Out-Null }
    Write-STClosing
}
