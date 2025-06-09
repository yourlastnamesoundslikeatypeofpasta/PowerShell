function Get-ServiceDeskStats {
    <#
    .SYNOPSIS
        Retrieves incident counts grouped by status over a date range.
    .DESCRIPTION
        Queries the Service Desk API for incidents created within the supplied
        start and end dates. The results are grouped by incident status and
        returned as a simple object with properties for each status name.
    .PARAMETER StartDate
        Beginning of the date range to query.
    .PARAMETER EndDate
        End of the date range to query.
    .PARAMETER ChaosMode
        Enables random delays and failures for chaos testing.
    .PARAMETER Explain
        Shows the full help content.
    .EXAMPLE
        Get-ServiceDeskStats -StartDate (Get-Date).AddDays(-7) -EndDate (Get-Date)

        Returns counts of incidents created in the last seven days grouped by status.
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory)]
        [datetime]$StartDate,
        [Parameter(Mandatory)]
        [datetime]$EndDate,
        [switch]$ChaosMode,
        [switch]$Explain
    )

    if (Show-STHelpWhenExplain -Explain:$Explain) { return }

    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $result = 'Success'
    Write-STLog -Message "Get-ServiceDeskStats" -Structured:$($env:ST_LOG_STRUCTURED -eq '1') -Metadata @{ start=$StartDate; end=$EndDate }
    try {
        $after  = [uri]::EscapeDataString($StartDate.ToString('yyyy-MM-dd'))
        $before = [uri]::EscapeDataString($EndDate.ToString('yyyy-MM-dd'))
        $path = "/incidents.json?created_after=$after&created_before=$before"
        if ($PSCmdlet.ShouldProcess('incidents', 'Get stats')) {
            $incidents = Invoke-SDRequest -Method 'GET' -Path $path -ChaosMode:$ChaosMode
            $counts = @{}
            foreach ($g in ($incidents | Group-Object -Property state)) { $counts[$g.Name] = $g.Count }
            return [pscustomobject]$counts
        }
    }
    catch {
        $result = 'Failure'
        Write-STLog -Message "Get-ServiceDeskStats failed: $_" -Level ERROR -Structured:$($env:ST_LOG_STRUCTURED -eq '1')
        throw
    }
    finally {
        $sw.Stop()
        Write-STTelemetryEvent -ScriptName 'Get-ServiceDeskStats' -Result $result -Duration $sw.Elapsed -Category 'ServiceDeskTools'
    }
}
