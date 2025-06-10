function Get-UniquePermission {
    <#
    .SYNOPSIS
        Returns items with unique permissions in a SharePoint site.

    .DESCRIPTION
        Wraps the `Get-UniquePermissions.ps1` script located in the `scripts`
        directory and outputs the results.

    .PARAMETER Arguments
        Additional parameters forwarded to `Get-UniquePermissions.ps1`.

    .PARAMETER TranscriptPath
        Optional path for a transcript log.

    .PARAMETER Simulate
        Perform a dry run without making changes.

    .PARAMETER Explain
        Display the help for `Get-UniquePermissions.ps1`.

    .PARAMETER Logger
        Optional instance of the Logging module used for output.

    .PARAMETER TelemetryClient
        Optional telemetry client used to record metrics.

    .PARAMETER Config
        Optional configuration object injected into the script.

    .EXAMPLE
        Get-UniquePermission -Arguments @('-SiteUrl','https://contoso.sharepoint.com/sites/team')

        Lists items with broken inheritance in the specified site collection.

    .NOTES
        Requires the PnP.PowerShell module and SharePoint administrative rights.
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
        if (-not $PSCmdlet.ShouldProcess('Get-UniquePermissions.ps1')) { return }
        try {
            $output = Invoke-ScriptFile -Logger $Logger -TelemetryClient $TelemetryClient -Config $Config -Name "Get-UniquePermissions.ps1" -Args $Arguments -TranscriptPath $TranscriptPath -Simulate:$Simulate -Explain:$Explain
        } catch {
            Write-Error $_.Exception.Message
            throw
        }
        return [pscustomobject]@{
            Script = 'Get-UniquePermissions.ps1'
            Result = $output
        }
    }
}
