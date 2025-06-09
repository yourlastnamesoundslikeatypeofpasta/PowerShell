function Invoke-PerformanceAudit {
    <#
    .SYNOPSIS
        Collects performance metrics for common tasks.

    .DESCRIPTION
        Wraps the `Invoke-PerformanceAudit.ps1` script located in the `scripts`
        folder.

    .PARAMETER Arguments
        Additional parameters forwarded to `Invoke-PerformanceAudit.ps1`.

    .PARAMETER TranscriptPath
        Optional path for a transcript log.

    .PARAMETER Simulate
        Perform a dry run without making changes.

    .PARAMETER Explain
        Display the help for `Invoke-PerformanceAudit.ps1`.

    .PARAMETER Logger
        Optional instance of the Logging module used for output.

    .PARAMETER TelemetryClient
        Optional telemetry client used to record metrics.

    .PARAMETER Config
        Optional configuration object injected into the script.

    .EXAMPLE
        Invoke-PerformanceAudit -Simulate

        Runs the audit in dry-run mode without writing data.

    .NOTES
        Metrics are written to the telemetry log for later analysis.
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory = $false, ValueFromRemainingArguments = $true, ValueFromPipeline = $true)][object[]]$Arguments,
        [Parameter(Mandatory = $false)] [ValidateNotNullOrEmpty()] [string]$TranscriptPath,
        [Parameter(Mandatory = $false)][switch]$Simulate,
        [Parameter(Mandatory = $false)][switch]$Explain,
        [Parameter(Mandatory = $false)][object]$Logger,
        [Parameter(Mandatory = $false)][object]$TelemetryClient,
        [Parameter(Mandatory = $false)][object]$Config
    )
    process {
        try {
            $output = Invoke-ScriptFile -Logger $Logger -TelemetryClient $TelemetryClient -Config $Config -Name 'Invoke-PerformanceAudit.ps1' -Args $Arguments -TranscriptPath $TranscriptPath -Simulate:$Simulate -Explain:$Explain
        } catch {
            Write-Error $_.Exception.Message
            throw
        }
        return [pscustomobject]@{
            Script = 'Invoke-PerformanceAudit.ps1'
            Result = $output
        }
    }
}
