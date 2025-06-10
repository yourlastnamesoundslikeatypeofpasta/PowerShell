function New-SPUsageReport {
    <#
    .SYNOPSIS
        Generate library usage CSV reports and create Service Desk tickets when limits are exceeded.

    .DESCRIPTION
        Wraps the `Generate-SPUsageReport.ps1` script in the `scripts` folder and forwards all parameters.

    .PARAMETER Arguments
        Additional parameters forwarded to `Generate-SPUsageReport.ps1`.

    .PARAMETER TranscriptPath
        Optional path for a transcript log.

    .PARAMETER Simulate
        Perform a dry run without taking action.

    .PARAMETER Explain
        Display the help for `Generate-SPUsageReport.ps1`.

    .PARAMETER Logger
        Optional instance of the Logging module used for output.

    .PARAMETER TelemetryClient
        Optional telemetry client used to record metrics.

    .PARAMETER Config
        Optional configuration object injected into the script.

    .EXAMPLE
        New-SPUsageReport -Arguments @('-SiteUrl','https://contoso.sharepoint.com/sites/files')

        Generates a usage report for the specified site collection.

    .NOTES
        Requires the PnP.PowerShell module and Service Desk API access when ticket creation is enabled.
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory = $false, ValueFromRemainingArguments = $true, ValueFromPipeline = $true)]
        [object[]]$Arguments,
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$TranscriptPath,
        [Parameter(Mandatory = $false)]
        [switch]$Simulate,
        [Parameter(Mandatory = $false)]
        [switch]$Explain,
        [Parameter(Mandatory = $false)]
        [object]$Logger,
        [Parameter(Mandatory = $false)]
        [object]$TelemetryClient,
        [Parameter(Mandatory = $false)]
        [object]$Config
    )
    process {
        if (-not $PSCmdlet.ShouldProcess('Generate-SPUsageReport.ps1')) { return }
        try {
            $output = Invoke-ScriptFile -Logger $Logger -TelemetryClient $TelemetryClient -Config $Config -Name 'Generate-SPUsageReport.ps1' -Args $Arguments -TranscriptPath $TranscriptPath -Simulate:$Simulate -Explain:$Explain
        } catch {
            Write-Error $_.Exception.Message
            throw
        }
        return [pscustomobject]@{
            Script = 'Generate-SPUsageReport.ps1'
            Result = $output
        }
    }
}
