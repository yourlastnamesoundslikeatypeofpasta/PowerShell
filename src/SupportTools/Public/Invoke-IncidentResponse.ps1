function Invoke-IncidentResponse {
    <#
    .SYNOPSIS
        Gather forensic data for incident response triage.
    .DESCRIPTION
        Wraps the Invoke-IncidentResponse.ps1 script located in the scripts folder.
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
        Invoke-ScriptFile -Name 'Invoke-IncidentResponse.ps1' -Args $Arguments -TranscriptPath $TranscriptPath -Simulate:$Simulate -Explain:$Explain
    }
}
