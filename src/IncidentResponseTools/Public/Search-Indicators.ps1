function Search-Indicators {
    <#
    .SYNOPSIS
        Search event logs, registry and file system for suspicious indicators.
    .DESCRIPTION
        Calls the Search-Indicators.ps1 script with the supplied indicator list.
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$IndicatorList,
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]$TranscriptPath,
        [Parameter(Mandatory=$false)]
        [switch]$Simulate,
        [Parameter(Mandatory=$false)]
        [switch]$Explain,
        [Parameter(Mandatory=$false)]
        [object]$Logger,
        [Parameter(Mandatory=$false)]
        [object]$TelemetryClient,
        [Parameter(Mandatory=$false)]
        [object]$Config
    )
    process {
        $arguments = @('-IndicatorList', $IndicatorList)
        Invoke-ScriptFile -Logger $Logger -TelemetryClient $TelemetryClient -Config $Config -Name 'Search-Indicators.ps1' -Args $arguments -TranscriptPath $TranscriptPath -Simulate:$Simulate -Explain:$Explain
    }
}
