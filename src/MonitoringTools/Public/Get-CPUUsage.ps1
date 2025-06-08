function Get-CPUUsage {
    <#
    .SYNOPSIS
        Returns current CPU utilization percentage.
    .DESCRIPTION
        Uses Get-Counter on the Processor(_Total)\% Processor Time counter and averages multiple samples.
    .PARAMETER Samples
        Number of samples to average. Default 3.
    #>
    [CmdletBinding()]
    param(
        [int]$Samples = 3
    )
    process {
        try {
            $counter = Get-Counter '\Processor(_Total)\% Processor Time' -SampleInterval 1 -MaxSamples $Samples
            return [math]::Round(($counter.CounterSamples | Measure-Object -Property CookedValue -Average).Average,2)
        } catch {
            Write-STStatus "Get-CPUUsage failed: $_" -Level ERROR -Log
            return New-STErrorObject -Message $_.Exception.Message -Category 'Performance'
        }
    }
}
