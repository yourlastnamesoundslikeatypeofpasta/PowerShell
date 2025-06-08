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
        ,[Parameter(Mandatory = $false)]
        [object]$Logger
        ,[Parameter(Mandatory = $false)]
        [object]$TelemetryClient
        ,[Parameter(Mandatory = $false)]
        [object]$Config
    )
    process {
        $output = Invoke-ScriptFile -Logger $Logger -TelemetryClient $TelemetryClient -Config $Config -Name 'Invoke-PerformanceAudit.ps1' -Args $Arguments -TranscriptPath $TranscriptPath -Simulate:$Simulate -Explain:$Explain
        return [pscustomobject]@{
            Script = 'Invoke-PerformanceAudit.ps1'
            Result = $output
        }
    }
}
