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
Import-Module (Join-Path $moduleRoot 'STCore/STCore.psd1') -Force -ErrorAction SilentlyContinue
if (-not (Get-Module -Name 'Logging')) {
    Import-Module (Join-Path $moduleRoot 'Logging/Logging.psd1') -Force -ErrorAction SilentlyContinue
}
if (-not (Get-Module -Name 'Telemetry')) {
    Import-Module (Join-Path $moduleRoot 'Telemetry/Telemetry.psd1') -Force -ErrorAction SilentlyContinue
}
if ($CreateTicket) {
    Import-Module (Join-Path $moduleRoot 'ServiceDeskTools/ServiceDeskTools.psd1') -Force -ErrorAction SilentlyContinue
}

if ($TranscriptPath) {
    Start-Transcript -Path $TranscriptPath -Append | Out-Null
}

$scriptName = Split-Path -Leaf $PSCommandPath
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
$result = 'Success'
$alerts = @()

try {
    Write-STDivider -Title 'PERFORMANCE AUDIT' -Style heavy

    # CPU usage
    if ($IsWindows -and (Get-Command Get-Counter -ErrorAction SilentlyContinue)) {
        $cpuSamples = Get-Counter '\Processor(_Total)\% Processor Time' -SampleInterval 1 -MaxSamples 3
        $cpuSampleValues = $cpuSamples.CounterSamples | Select-Object -ExpandProperty CookedValue
        $cpuUsage = [math]::Round(($cpuSampleValues | Measure-Object -Average).Average,2)
    } elseif (-not $IsWindows -and (Get-Command ps -ErrorAction SilentlyContinue)) {
        $cpuSampleValues = ps -A -o %cpu | Select-Object -Skip 1 | ForEach-Object { $_ -as [double] }
        if ($cpuSampleValues) {
            $cpuUsage = [math]::Round(($cpuSampleValues | Measure-Object -Average).Average,2)
        } else {
            $cpuUsage = $null
            Write-STStatus -Message 'Unable to read CPU usage from ps.' -Level WARN -Log
        }
    } else {
        $cpuUsage = $null
        $cpuSampleValues = @()
        Write-STStatus -Message 'CPU metrics skipped: required tools not found.' -Level WARN -Log
    }
    Write-STLog -Metric 'CPUPercent' -Value $cpuUsage -Structured
    Send-STMetric -MetricName 'CPUPercent' -Category 'Audit' -Value $cpuUsage

    # Memory usage
    if ($IsWindows) {
        $os = Get-CimInstance -ClassName Win32_OperatingSystem
        $memUsedPct = [math]::Round((($os.TotalVisibleMemorySize - $os.FreePhysicalMemory) / $os.TotalVisibleMemorySize) * 100,2)
    } elseif (Test-Path '/proc/meminfo') {
        $memInfo = Get-Content /proc/meminfo
        $total = ($memInfo | Where-Object { $_ -match '^MemTotal:' }) -replace '\D+', ''
        $avail = ($memInfo | Where-Object { $_ -match '^MemAvailable:' }) -replace '\D+', ''
        $memUsedPct = [math]::Round(((($total - $avail) / $total) * 100),2)
    } else {
        $memUsedPct = $null
        Write-STStatus -Message 'Memory metrics skipped: unsupported platform.' -Level WARN -Log
    }
    Write-STLog -Metric 'MemoryPercent' -Value $memUsedPct -Structured
    Send-STMetric -MetricName 'MemoryPercent' -Category 'Audit' -Value $memUsedPct

    # Disk utilisation
    if ($IsWindows -and (Get-Command Get-Counter -ErrorAction SilentlyContinue)) {
        $diskSamples = Get-Counter '\PhysicalDisk(_Total)\% Disk Time' -SampleInterval 1 -MaxSamples 3
        $diskSampleValues = $diskSamples.CounterSamples | Select-Object -ExpandProperty CookedValue
        $diskUsage = [math]::Round(($diskSampleValues | Measure-Object -Average).Average,2)
    } elseif (-not $IsWindows -and (Get-Command df -ErrorAction SilentlyContinue)) {
        $diskLine = df -P --total | Select-String '^total' | ForEach-Object { $_.ToString() }
        if ($diskLine) {
            $diskUsage = [double]($diskLine -split '\s+')[4].TrimEnd('%')
            $diskSampleValues = @($diskUsage)
        } else {
            $diskUsage = $null
            $diskSampleValues = @()
            Write-STStatus -Message 'Unable to read disk usage from df.' -Level WARN -Log
        }
    } else {
        $diskUsage = $null
        $diskSampleValues = @()
        Write-STStatus -Message 'Disk metrics skipped: required tools not found.' -Level WARN -Log
    }
    Write-STLog -Metric 'DiskPercent' -Value $diskUsage -Structured
    Send-STMetric -MetricName 'DiskPercent' -Category 'Audit' -Value $diskUsage

    # Network usage (Mbps)
    if ($IsWindows -and (Get-Command Get-Counter -ErrorAction SilentlyContinue)) {
        $netSamples = Get-Counter '\Network Interface(*)\Bytes Total/sec' -SampleInterval 1 -MaxSamples 3
        $netBytes = ($netSamples.CounterSamples | Measure-Object -Property CookedValue -Sum).Sum / $netSamples.CounterSamples.Count
        $netMbps = [math]::Round(($netBytes * 8) / 1MB,2)
    } else {
        $netMbps = $null
        Write-STStatus -Message 'Network metrics skipped on non-Windows.' -Level WARN -Log
    }
    Write-STLog -Metric 'NetworkMbps' -Value $netMbps -Structured
    Send-STMetric -MetricName 'NetworkMbps' -Category 'Audit' -Value $netMbps

    # Uptime
    $uptime = (Get-Uptime).ToString()
    Write-STLog -Message "Uptime: $uptime" -Structured

    $report = [pscustomobject]@{
        CpuPercent     = $cpuUsage
        CpuSamples     = $cpuSampleValues
        MemoryPercent  = $memUsedPct
        DiskPercent    = $diskUsage
        DiskSamples    = $diskSampleValues
        NetworkMbps    = $netMbps
        Uptime         = $uptime
    }

    Write-STBlock -Data $report

    if ($cpuUsage -gt $CpuThreshold)    { $alerts += "CPU usage $cpuUsage% > $CpuThreshold%" }
    if ($memUsedPct -gt $MemoryThreshold) { $alerts += "Memory usage $memUsedPct% > $MemoryThreshold%" }
    if ($diskUsage -gt $DiskThreshold)  { $alerts += "Disk usage $diskUsage% > $DiskThreshold%" }
    if ($netMbps -gt $NetworkThreshold) { $alerts += "Network usage $netMbps Mbps > $NetworkThreshold Mbps" }

    if ($alerts.Count -gt 0) {
        Write-STStatus -Message 'Performance thresholds exceeded:' -Level WARN -Log
        foreach ($alert in $alerts) { Write-STStatus -Message $alert -Level WARN -Log }
    } else {
        Write-STStatus -Message 'All metrics within thresholds.' -Level SUCCESS -Log
    }

    if ($CreateTicket -and $alerts.Count -gt 0) {
        if (-not $RequesterEmail) { throw 'RequesterEmail is required when creating a ticket.' }
        $subject = "Performance alert on $env:COMPUTERNAME"
        $desc = $alerts -join '\n'
        $ticket = New-SDTicket -Subject $subject -Description $desc -RequesterEmail $RequesterEmail
        Write-STStatus -Message "Created Service Desk ticket ID $($ticket.id)" -Level SUCCESS -Log
        $report | Add-Member -NotePropertyName TicketId -NotePropertyValue $ticket.id -Force
    }

    $report
} catch {
    Write-STStatus -Message "Audit failed: $_" -Level ERROR -Log
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
