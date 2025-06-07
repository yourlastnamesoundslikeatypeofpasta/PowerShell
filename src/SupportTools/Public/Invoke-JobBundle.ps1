function Invoke-JobBundle {
    <#
    .SYNOPSIS
        Runs a job packaged as a .job.zip bundle.
    .DESCRIPTION
        Unpacks the specified bundle, executes the job script described in
        job.json and archives the transcript and SupportTools log.
    .PARAMETER Path
        Path to the job bundle (.job.zip).
    .PARAMETER LogArchivePath
        Optional path to save the resulting log archive. Defaults to
        '<bundle>.logs.zip'.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,ValueFromPipelineByPropertyName=$true)]
        [string]$Path,
        [string]$LogArchivePath
    )

    process {
        if (-not $LogArchivePath) {
            $LogArchivePath = $Path -replace '\\.zip$','-logs.zip'
        }

        $transcript = [IO.Path]::GetTempFileName()
        $args = @('-BundlePath', $Path)
        Invoke-ScriptFile -Logger $Logger -TelemetryClient $TelemetryClient -Config $Config -Name 'Run-JobBundle.ps1' -Args $args -TranscriptPath $transcript

        $logFile = if ($env:ST_LOG_PATH) {
            $env:ST_LOG_PATH
        } else {
            $profile = if ($env:USERPROFILE) { $env:USERPROFILE } else { $env:HOME }
            Join-Path (Join-Path $profile 'SupportToolsLogs') 'supporttools.log'
        }

        $files = @($transcript)
        if (Test-Path $logFile) { $files += $logFile }
        Compress-Archive -Path $files -DestinationPath $LogArchivePath -Force
        Remove-Item $transcript -Force
        Write-STStatus "Logs archived to $LogArchivePath" -Level SUCCESS
    }
}
