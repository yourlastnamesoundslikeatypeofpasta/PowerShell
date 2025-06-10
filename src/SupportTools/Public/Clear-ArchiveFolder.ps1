function Clear-ArchiveFolder {
    <#
    .SYNOPSIS
        Removes files and folders from the archived SharePoint directory.

    .DESCRIPTION
        Wraps the `CleanupArchive.ps1` script located in the `scripts` folder.
        All parameters are forwarded allowing you to control the cleanup
        behaviour.

    .PARAMETER Arguments
        Additional parameters passed directly to `CleanupArchive.ps1`.

    .PARAMETER TranscriptPath
        Optional path for a transcript log of the operation.

    .PARAMETER Simulate
        Perform a dry run without deleting any items.

    .PARAMETER Explain
        Display the help for `CleanupArchive.ps1` instead of executing it.

    .PARAMETER Logger
        Optional instance of the Logging module used for output.

    .PARAMETER TelemetryClient
        Optional telemetry client used to record metrics.

    .PARAMETER Config
        Optional configuration object injected into the script.

    .EXAMPLE
        Clear-ArchiveFolder -Arguments @('-SiteUrl','https://contoso.sharepoint.com/sites/archive') -Simulate

        Runs the cleanup script against the specified SharePoint site in dry
        run mode.

    .NOTES
        Requires SharePoint administrator permissions and the PnP.PowerShell
        module.
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
        if (-not $PSCmdlet.ShouldProcess('CleanupArchive.ps1')) { return }
        try {
            $output = Invoke-ScriptFile -Logger $Logger -TelemetryClient $TelemetryClient -Config $Config -Name "CleanupArchive.ps1" -Args $Arguments -TranscriptPath $TranscriptPath -Simulate:$Simulate -Explain:$Explain
        } catch {
            Write-Error $_.Exception.Message
            throw
        }
        return [pscustomobject]@{
            Script = 'CleanupArchive.ps1'
            Result = $output
        }
    }
}
