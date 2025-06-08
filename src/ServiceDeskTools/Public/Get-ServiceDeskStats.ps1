function Get-ServiceDeskStats {
    <#
    .SYNOPSIS
        Returns counts of incidents by state for the specified date range.
    .PARAMETER From
        Start date/time for the query filter.
    .PARAMETER To
        End date/time for the query filter.
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)][datetime]$From,
        [Parameter(Mandatory)][datetime]$To,
        [switch]$ChaosMode,
        [switch]$Explain
    )

    if ($Explain) {
        Get-Help $MyInvocation.PSCommandPath -Full
        return
    }

    Write-STLog -Message "Get-ServiceDeskStats $From $To"
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $result = 'Success'
    try {
        $fromStr = [Uri]::EscapeDataString($From.ToString('yyyy-MM-dd'))
        $toStr = [Uri]::EscapeDataString($To.ToString('yyyy-MM-dd'))
        $path = "/incidents.json?created_after=$fromStr&created_before=$toStr"
        if ($PSCmdlet.ShouldProcess("incidents", "Get stats $From to $To")) {
            $incidents = Invoke-SDRequest -Method 'GET' -Path $path -ChaosMode:$ChaosMode
            if (-not $incidents) { $incidents = @() }
            $groups = $incidents | Group-Object -Property state
            $stats = [ordered]@{ Total = $incidents.Count }
            foreach ($g in $groups) { $stats[$g.Name] = $g.Count }
            return [pscustomobject]$stats
        }
    } catch {
        $result = 'Failure'
        throw
    } finally {
        $sw.Stop()
        Send-STMetric -MetricName 'Get-ServiceDeskStats' -Category 'ServiceDeskTools' -Value $sw.Elapsed.TotalSeconds -Details @{ Result = $result }
    }
}
