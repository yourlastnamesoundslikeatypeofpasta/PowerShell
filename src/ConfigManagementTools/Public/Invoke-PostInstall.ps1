function Invoke-PostInstall {
    <#
    .SYNOPSIS
        Executes the automated post installation script.
    .DESCRIPTION
        Runs PostInstallScript.ps1 from the scripts folder, forwarding any
        arguments provided.
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory = $false, ValueFromRemainingArguments = $true, ValueFromPipeline = $true)]
        [object[]]$Arguments,
        [Parameter(Mandatory = $false)]
        [string]$DomainName,
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
        if ($PSCmdlet.ShouldProcess('PostInstallScript.ps1')) {
            $argList = @()
            if ($DomainName) { $argList += '-DomainName'; $argList += $DomainName }
            if ($Arguments) { $argList += $Arguments }
            Invoke-ScriptFile -Logger $Logger -TelemetryClient $TelemetryClient -Config $Config -Name "PostInstallScript.ps1" -Args $argList -TranscriptPath $TranscriptPath -Simulate:$Simulate -Explain:$Explain
        }
    }
}
