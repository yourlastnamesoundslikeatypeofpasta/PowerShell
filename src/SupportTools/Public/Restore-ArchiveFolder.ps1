function Restore-ArchiveFolder {
    <#
    .SYNOPSIS
        Restores files and folders removed by Clear-ArchiveFolder.

    .DESCRIPTION
        Wraps the `RollbackArchive.ps1` script in the `scripts` folder. All
        parameters are forwarded to that script.

    .PARAMETER Arguments
        Additional parameters passed directly to `RollbackArchive.ps1`.

    .PARAMETER TranscriptPath
        Optional path for a transcript log.

    .PARAMETER Simulate
        Perform a dry run without restoring items.

    .PARAMETER Explain
        Display the help for `RollbackArchive.ps1`.

    .PARAMETER Logger
        Optional instance of the Logging module used for output.

    .PARAMETER TelemetryClient
        Optional telemetry client used to record metrics.

    .PARAMETER Config
        Optional configuration object injected into the script.

    .EXAMPLE
        Restore-ArchiveFolder -Arguments @('-SnapshotPath','preDeleteLog.json')

        Restores files previously removed by `Clear-ArchiveFolder` using the
        specified snapshot.

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
        if ($PSCmdlet.ShouldProcess('RollbackArchive.ps1')) {
            try {
                $output = Invoke-ScriptFile -Logger $Logger -TelemetryClient $TelemetryClient -Config $Config -Name "RollbackArchive.ps1" -Args $Arguments -TranscriptPath $TranscriptPath -Simulate:$Simulate -Explain:$Explain
            } catch {
                Write-Error $_.Exception.Message
                throw
            }
            return [pscustomobject]@{
                Script = 'RollbackArchive.ps1'
                Result = $output
            }
        }
    }
}
