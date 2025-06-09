function Invoke-PostInstall {
    <#
    .SYNOPSIS
        Executes the automated post installation script.
    .DESCRIPTION
        Runs PostInstallScript.ps1 from the scripts folder, forwarding any
        arguments provided.
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
        Invoke-ScriptFile -Logger $Logger -TelemetryClient $TelemetryClient -Config $Config -Name "PostInstallScript.ps1" -Args $Arguments -TranscriptPath $TranscriptPath -Simulate:$Simulate -Explain:$Explain
    }
}
