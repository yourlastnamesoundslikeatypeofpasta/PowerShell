function Invoke-PerformanceAudit {
    <#
    .SYNOPSIS
        Collects performance metrics for common tasks.
    .DESCRIPTION
        Runs the Invoke-PerformanceAudit.ps1 script located in the scripts folder.
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
        Invoke-ScriptFile -Logger $Logger -TelemetryClient $TelemetryClient -Config $Config -Name 'Invoke-PerformanceAudit.ps1' -Args $Arguments -TranscriptPath $TranscriptPath -Simulate:$Simulate -Explain:$Explain
    }
}
