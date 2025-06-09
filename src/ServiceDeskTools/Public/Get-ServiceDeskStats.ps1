function Get-ServiceDeskStats {
    <#
    .SYNOPSIS
        Retrieves incident counts grouped by status.
    .PARAMETER StartDate
        Beginning of the date range to query.
    .PARAMETER EndDate
        End of the date range to query.
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory)][datetime]$StartDate,
        [Parameter(Mandatory)][datetime]$EndDate,
        [switch]$ChaosMode,
        [switch]$Explain
    )

    if ($Explain) {
        Get-Help $MyInvocation.PSCommandPath -Full
        return
    }

    $sw     = [System.Diagnostics.Stopwatch]::StartNew()
    $result = 'Success'
    try {
        Write-STLog -Message "Get-ServiceDeskStats $StartDate $EndDate"
        $after  = $StartDate.ToString('yyyy-MM-dd')
        $before = $EndDate.ToString('yyyy-MM-dd')
        $path   = "/incidents.json?created_after=$after&created_before=$before"
        if ($PSCmdlet.ShouldProcess('incidents', "Get stats $after to $before")) {
            $data = Invoke-SDRequest -Method 'GET' -Path $path -ChaosMode:$ChaosMode
        } else { return }
        $counts = @{}
        foreach ($g in ($data | Group-Object -Property state)) {
            $counts[$g.Name] = $g.Count
        }
        return [pscustomobject]$counts
    } catch {
        $result = 'Failure'
        Write-STLog -Message "Get-ServiceDeskStats failed: $_" -Level ERROR
        throw
    } finally {
        $sw.Stop()
        Write-STTelemetryEvent -ScriptName 'Get-ServiceDeskStats' -Result $result -Duration $sw.Elapsed
    }
}
