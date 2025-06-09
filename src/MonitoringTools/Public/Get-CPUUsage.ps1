function Get-CPUUsage {
    <#
    .SYNOPSIS
        Gets the current CPU utilisation percentage.
    .DESCRIPTION
        Uses Get-Counter on Windows to calculate average CPU usage. On
        non-Windows systems the command falls back to `ps` if available or
        logs a warning when CPU metrics cannot be collected. Each call also
        records a structured log entry via Write-STRichLog.
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param()

    if (-not $PSCmdlet.ShouldProcess('CPU usage')) { return }

    $computer = if ($env:COMPUTERNAME) { $env:COMPUTERNAME } else { $env:HOSTNAME }
    $timestamp = (Get-Date).ToString('o')
    $cpu = $null
    if ($IsWindows -and (Get-Command Get-Counter -ErrorAction SilentlyContinue)) {
        $samples = Get-Counter '\\Processor(_Total)\\% Processor Time' -SampleInterval 1 -MaxSamples 3
        $cpu = [math]::Round(($samples.CounterSamples | Measure-Object -Property CookedValue -Average).Average,2)
    } elseif (-not $IsWindows -and (Get-Command ps -ErrorAction SilentlyContinue)) {
        $cpuValues = ps -A -o %cpu | Select-Object -Skip 1 | ForEach-Object { $_ -as [double] }
        if ($cpuValues) {
            $cpu = [math]::Round(($cpuValues | Measure-Object -Average).Average,2)
        } else {
            Write-STStatus -Message 'Unable to read CPU usage from ps.' -Level WARN
        }
    } else {
        Write-STStatus -Message 'CPU metrics skipped: required tools not found.' -Level WARN
    }
    $json = @{ ComputerName = $computer; CpuPercent = $cpu; Timestamp = $timestamp } | ConvertTo-Json -Compress
    Write-STRichLog -Tool 'Get-CPUUsage' -Status 'queried' -Details $json
    return $cpu
}
