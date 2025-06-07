function Invoke-PerformanceAudit {
    <#
    .SYNOPSIS
        Collects performance metrics for common tasks.
    .DESCRIPTION
        Runs the Invoke-PerformanceAudit.ps1 script located in the scripts folder.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false, ValueFromRemainingArguments = $true, ValueFromPipeline = $true)]
        [object[]]$Arguments,
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$TranscriptPath,
        [Parameter(Mandatory = $false)]
        [switch]$Simulate,
        [Parameter(Mandatory = $false)]
        [switch]$Explain
    )
    process {
        Invoke-ScriptFile -Name 'Invoke-PerformanceAudit.ps1' -Args $Arguments -TranscriptPath $TranscriptPath -Simulate:$Simulate -Explain:$Explain
    }
}
