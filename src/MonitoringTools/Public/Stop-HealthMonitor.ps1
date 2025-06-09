function Stop-HealthMonitor {
    <#
    .SYNOPSIS
        Signals Start-HealthMonitor to stop collecting health samples.
    .DESCRIPTION
        Sets a script-scoped flag consumed by Start-HealthMonitor so that the
        monitoring loop exits on the next iteration.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param()

    if (-not $PSCmdlet.ShouldProcess('stop health monitor')) { return }

    $script:StopHealthMonitor = $true
}
