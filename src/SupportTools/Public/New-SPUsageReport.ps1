function New-SPUsageReport {
    <#
    .SYNOPSIS
        Generate library usage CSV reports and create Service Desk tickets when limits are exceeded.
    .DESCRIPTION
        This is a wrapper for the Generate-SPUsageReport.ps1 script in the scripts folder.
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true, ValueFromPipeline=$true)]
        [object[]]$Arguments,
        [string]$TranscriptPath,
        [switch]$Simulate,
        [switch]$Explain,
        [object]$Logger,
        [object]$TelemetryClient,
        [object]$Config
    )
    process {
        Invoke-ScriptFile -Logger $Logger -TelemetryClient $TelemetryClient -Config $Config -Name 'Generate-SPUsageReport.ps1' -Args $Arguments -TranscriptPath $TranscriptPath -Simulate:$Simulate -Explain:$Explain
    }
}
