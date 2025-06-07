function Invoke-IncidentResponse {
    <#
    .SYNOPSIS
        Gather forensic data for incident response triage.
    .DESCRIPTION
        Wraps the Invoke-IncidentResponse.ps1 script located in the scripts folder.
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true, ValueFromPipeline=$true)]
        [object[]]$Arguments,
        [string]$TranscriptPath,
        [switch]$Simulate,
        [switch]$Explain
    )
    process {
        Invoke-ScriptFile -Name 'Invoke-IncidentResponse.ps1' -Args $Arguments -TranscriptPath $TranscriptPath -Simulate:$Simulate -Explain:$Explain
    }
}
