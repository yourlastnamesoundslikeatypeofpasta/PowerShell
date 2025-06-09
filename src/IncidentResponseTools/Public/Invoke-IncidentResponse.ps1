function Invoke-IncidentResponse {
    <#
    .SYNOPSIS
        Gather forensic data for incident response triage.
    .DESCRIPTION
        Wraps the Invoke-IncidentResponse.ps1 script located in the scripts folder.
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
        [switch]$Explain
        ,[Parameter(Mandatory = $false)]
        [object]$Logger
        ,[Parameter(Mandatory = $false)]
        [object]$TelemetryClient
        ,[Parameter(Mandatory = $false)]
        [object]$Config
    )
    process {
        if (-not $PSCmdlet.ShouldProcess('incident response collection')) { return }
        Invoke-ScriptFile -Logger $Logger -TelemetryClient $TelemetryClient -Config $Config -Name 'Invoke-IncidentResponse.ps1' -Args $Arguments -TranscriptPath $TranscriptPath -Simulate:$Simulate -Explain:$Explain
    }
}
