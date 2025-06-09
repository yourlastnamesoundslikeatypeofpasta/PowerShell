function Get-CPUUsage {
    <#
    .SYNOPSIS
        Gets the current CPU utilisation percentage.
    .DESCRIPTION
        Uses Get-Counter when available to calculate average CPU usage.
        Each call also records a structured log entry via Write-STRichLog.
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param()

    $computer = if ($env:COMPUTERNAME) { $env:COMPUTERNAME } else { $env:HOSTNAME }
    $timestamp = (Get-Date).ToString('o')
    $cpu = $null
    if (Get-Command Get-Counter -ErrorAction SilentlyContinue) {
        $samples = Get-Counter '\\Processor(_Total)\\% Processor Time' -SampleInterval 1 -MaxSamples 3
        $cpu = [math]::Round(($samples.CounterSamples | Measure-Object -Property CookedValue -Average).Average,2)
    } else {
        Write-Warning 'Get-Counter not available.'
    }
    $json = @{ ComputerName = $computer; CpuPercent = $cpu; Timestamp = $timestamp } | ConvertTo-Json -Compress
    Write-STRichLog -Tool 'Get-CPUUsage' -Status 'queried' -Details $json
    return $cpu
}
