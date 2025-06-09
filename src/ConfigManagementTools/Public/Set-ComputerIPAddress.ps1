function Set-ComputerIPAddress {
    <#
    .SYNOPSIS
        Configures the IP address of a local or remote computer.
    .DESCRIPTION
        Wraps the Set-ComputerIPAddress.ps1 script, forwarding all arguments.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
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
        Invoke-ScriptFile -Logger $Logger -TelemetryClient $TelemetryClient -Config $Config -Name "Set-ComputerIPAddress.ps1" -Args $Arguments -TranscriptPath $TranscriptPath -Simulate:$Simulate -Explain:$Explain
    }
}
