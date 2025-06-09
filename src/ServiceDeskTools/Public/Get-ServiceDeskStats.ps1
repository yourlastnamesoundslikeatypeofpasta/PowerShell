function Get-ServiceDeskStats {
    <#
    .SYNOPSIS
        Returns incident counts grouped by status.
    .DESCRIPTION
        Queries the Service Desk API for incidents updated within the provided
        date range. Results are grouped by the incident state and returned as an
        object with properties for each state.
    .PARAMETER StartDate
        Only incidents updated after this time are included.
    .PARAMETER EndDate
        Only incidents updated before this time are included.
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)]
        [datetime]$StartDate,
        [datetime]$EndDate,
        [switch]$ChaosMode,
        [switch]$Explain
    )

    if ($Explain) {
        Get-Help $MyInvocation.PSCommandPath -Full
        return
    }

    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    Write-STLog -Message "Get-ServiceDeskStats $StartDate $EndDate" -Structured -Metadata @{ start = $StartDate; end = $EndDate }
    $result = 'Success'
    try {
        $path = "/incidents.json?updated_after=$([uri]::EscapeDataString($StartDate.ToString('o')) )"
        if ($EndDate) {
            $path += "&updated_before=$([uri]::EscapeDataString($EndDate.ToString('o')) )"
        }
        if ($PSCmdlet.ShouldProcess('incidents', 'Retrieve statistics')) {
            $data = Invoke-SDRequest -Method 'GET' -Path $path -ChaosMode:$ChaosMode
            $groups = $data | Group-Object -Property state
            $stats = @{}
            foreach ($g in $groups) { $stats[$g.Name] = $g.Count }
            return [pscustomobject]$stats
        }
    } catch {
        $result = 'Failure'
        Write-STLog -Message "Get-ServiceDeskStats failed: $_" -Level ERROR
        throw
    } finally {
        $sw.Stop()
        Write-STTelemetryEvent -ScriptName 'Get-ServiceDeskStats' -Result $result -Duration $sw.Elapsed
    }
}
