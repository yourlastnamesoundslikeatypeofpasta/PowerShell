function Get-CPUUsage {
    <#
    .SYNOPSIS
        Gets the current CPU utilisation percentage.
    .DESCRIPTION
        Uses Get-Counter when available to calculate average CPU usage.
        Logs the result via Write-STRichLog including computer name and timestamp.
    #>
    [CmdletBinding()]
    param()

    $computer = if ($env:COMPUTERNAME) { $env:COMPUTERNAME } else { $env:HOSTNAME }
    $time = Get-Date -Format 'o'

    if (Get-Command Get-Counter -ErrorAction SilentlyContinue) {
        $samples = Get-Counter '\\Processor(_Total)\\% Processor Time' -SampleInterval 1 -MaxSamples 3
        $cpu = [math]::Round(($samples.CounterSamples | Measure-Object -Property CookedValue -Average).Average,2)
        Write-STRichLog -Tool 'Get-CPUUsage' -Status 'success' -Details @("ComputerName=$computer","Timestamp=$time","CpuPercent=$cpu")
        return $cpu
    } else {
        Write-Warning 'Get-Counter not available.'
        Write-STRichLog -Tool 'Get-CPUUsage' -Status 'error' -Details @("ComputerName=$computer","Timestamp=$time","Reason=Get-Counter not available")
        return $null
    }
}
