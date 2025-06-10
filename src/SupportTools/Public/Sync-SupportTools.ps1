function Sync-SupportTools {
    <#
    .SYNOPSIS
        Updates the SupportTools modules from a git repository.
    .DESCRIPTION
        Clones the repository if it does not exist locally, otherwise pulls the latest changes.
        The module manifests under the `src` folder are imported after synchronization.
    .PARAMETER RepositoryUrl
        URL of the git repository to sync.
    .PARAMETER InstallPath
        Directory to clone or update the repository.
    .PARAMETER TranscriptPath
        Optional path for a transcript log of the synchronization.
    .PARAMETER Explain
        Display the full help for this command.
    .PARAMETER Logger
        Optional instance of the Logging module used for output.
    .PARAMETER TelemetryClient
        Optional telemetry client used to record metrics.
    .PARAMETER Config
        Optional configuration object injected into the script.
    .EXAMPLE
        Sync-SupportTools -RepositoryUrl https://git.example.com/SupportTools.git -InstallPath ~/SupportTools

        Clones the repository if needed and imports the module manifests from the `src` directory.

    .NOTES
        Git must be installed and available on the system PATH.
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$RepositoryUrl = '<internal repo URL>',
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$InstallPath = $(if ($env:USERPROFILE) { Join-Path $env:USERPROFILE 'SupportTools' } else { Join-Path $env:HOME 'SupportTools' }),
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$TranscriptPath,
        [Parameter(Mandatory = $false)]
        [switch]$Explain,
        [Parameter(Mandatory = $false)]
        [object]$Logger,
        [Parameter(Mandatory = $false)]
        [object]$TelemetryClient,
        [Parameter(Mandatory = $false)]
        [object]$Config
    )

    try {
        if (-not $PSCmdlet.ShouldProcess($InstallPath, 'Synchronize SupportTools repository')) { return }
        if ($TranscriptPath) { Start-Transcript -Path $TranscriptPath -Append | Out-Null }
        if ($Logger) {
            Import-Module $Logger -Force -ErrorAction SilentlyContinue
        } else {
            Import-Module (Join-Path $PSScriptRoot '../../Logging/Logging.psd1') -Force -ErrorAction SilentlyContinue
        }
        if ($TelemetryClient) {
            Import-Module $TelemetryClient -Force -ErrorAction SilentlyContinue
        } else {
            Import-Module (Join-Path $PSScriptRoot '../../Telemetry/Telemetry.psd1') -Force -ErrorAction SilentlyContinue
        }
        if ($Config) {
            Import-Module $Config -Force -ErrorAction SilentlyContinue
        }

        if ($Explain) {
            Get-Help $MyInvocation.PSCommandPath -Full
            return
        }

        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        $result = 'Success'
        if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
            Write-STStatus -Message 'Git is required but was not found in PATH.' -Level WARN
            throw 'Git is required but was not found in PATH.'
        }
        if (Test-Path (Join-Path $InstallPath '.git')) {
            git -C $InstallPath pull
        }
        else {
            git clone $RepositoryUrl $InstallPath
        }

        Import-Module (Join-Path $InstallPath 'src/SupportTools/SupportTools.psd1') -Force
        $sp = Join-Path $InstallPath 'src/SharePointTools/SharePointTools.psd1'
        if (Test-Path $sp) { Import-Module $sp -Force -ErrorAction SilentlyContinue }
        $sd = Join-Path $InstallPath 'src/ServiceDeskTools/ServiceDeskTools.psd1'
        if (Test-Path $sd) { Import-Module $sd -Force -ErrorAction SilentlyContinue }

        Write-STStatus -Message 'SupportTools synchronized' -Level FINAL
        return [pscustomobject]@{
            RepositoryUrl = $RepositoryUrl
            InstallPath   = $InstallPath
            Result        = 'Success'
        }
    } catch {
        Write-STStatus "Sync-SupportTools failed: $_" -Level ERROR -Log
        Write-STLog -Message "Sync-SupportTools failed: $_" -Level ERROR
        $result = 'Failure'
        return New-STErrorRecord -Message $_.Exception.Message -Exception $_.Exception
    } finally {
        if ($TranscriptPath) { Stop-Transcript | Out-Null }
        $sw.Stop()
        Send-STMetric -MetricName 'Sync-SupportTools' -Category 'Deployment' -Value $sw.Elapsed.TotalSeconds -Details @{ Result = $result }
    }
}
