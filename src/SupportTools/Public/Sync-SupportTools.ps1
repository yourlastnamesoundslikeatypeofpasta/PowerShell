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
    #>
    [CmdletBinding()]
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
        if ($TranscriptPath) { Start-Transcript -Path $TranscriptPath -Append | Out-Null }
        if ($Logger) {
            Import-Module $Logger -ErrorAction SilentlyContinue
        } else {
            Import-Module (Join-Path $PSScriptRoot '../../Logging/Logging.psd1') -ErrorAction SilentlyContinue
        }
        if ($TelemetryClient) {
            Import-Module $TelemetryClient -ErrorAction SilentlyContinue
        } else {
            Import-Module (Join-Path $PSScriptRoot '../../Telemetry/Telemetry.psd1') -ErrorAction SilentlyContinue
        }
        if ($Config) {
            Import-Module $Config -ErrorAction SilentlyContinue
        }

        if ($Explain) {
            Get-Help $MyInvocation.PSCommandPath -Full
            return
        }

        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        $result = 'Success'
        if (Test-Path (Join-Path $InstallPath '.git')) {
            git -C $InstallPath pull
        }
        else {
            git clone $RepositoryUrl $InstallPath
        }

        Import-Module (Join-Path $InstallPath 'src/SupportTools/SupportTools.psd1') -Force
        $sp = Join-Path $InstallPath 'src/SharePointTools/SharePointTools.psd1'
        if (Test-Path $sp) { Import-Module $sp -ErrorAction SilentlyContinue }
        $sd = Join-Path $InstallPath 'src/ServiceDeskTools/ServiceDeskTools.psd1'
        if (Test-Path $sd) { Import-Module $sd -ErrorAction SilentlyContinue }

        Write-STStatus 'SupportTools synchronized' -Level FINAL
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
