function Set-NetAdapterMetering {
    <#
    .SYNOPSIS
        Toggles the metered connection flag on a network adapter.
    .DESCRIPTION
        Invokes the Set-NetAdapterMetering.ps1 script with any supplied
        arguments.
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
        Invoke-ScriptFile -Logger $Logger -TelemetryClient $TelemetryClient -Config $Config -Name "Set-NetAdapterMetering.ps1" -Args $Arguments -TranscriptPath $TranscriptPath -Simulate:$Simulate -Explain:$Explain
    }
}
