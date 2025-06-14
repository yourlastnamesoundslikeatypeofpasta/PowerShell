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
    .EXAMPLE
        Invoke-JobBundle -Path ./MyJob.job.zip -LogArchivePath ./MyJob.logs.zip

        Executes the job bundle and archives the transcript and log output to
        `MyJob.logs.zip`.

    .NOTES
        The bundle must contain a `job.json` file describing the job script to
        run.
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$LogArchivePath
    )

    process {
        if (-not $LogArchivePath) {
            $LogArchivePath = $Path -replace '\\.zip$','-logs.zip'
        }

        if ($PSCmdlet.ShouldProcess('Run-JobBundle.ps1')) {
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
            try {
                Compress-Archive -Path $files -DestinationPath $LogArchivePath -Force -ErrorAction Stop
                Remove-Item $transcript -Force -ErrorAction Stop
            } catch {
                Write-Error $_.Exception.Message
                throw
            }
            Write-STStatus "Logs archived to $LogArchivePath" -Level SUCCESS
            return [pscustomobject]@{
                LogArchivePath = $LogArchivePath
            }
        }
    }
}
