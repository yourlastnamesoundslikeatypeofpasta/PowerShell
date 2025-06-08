function Get-CPUUsage {
    <#
    .SYNOPSIS
        Gets the current CPU utilisation percentage.
    .DESCRIPTION
        Uses Get-Counter when available to calculate average CPU usage.
    #>
    [CmdletBinding()]
    param()

    if (Get-Command Get-Counter -ErrorAction SilentlyContinue) {
        $samples = Get-Counter '\\Processor(_Total)\\% Processor Time' -SampleInterval 1 -MaxSamples 3
        return [math]::Round(($samples.CounterSamples | Measure-Object -Property CookedValue -Average).Average,2)
    } else {
        Write-Warning 'Get-Counter not available.'
        return $null
    }
}
