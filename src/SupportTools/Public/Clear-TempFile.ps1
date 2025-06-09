function Clear-TempFile {
    <#
    .SYNOPSIS
        Removes temporary files from the repository.

    .DESCRIPTION
        Deletes any `*.tmp` files and empty `*.log` files starting at the
        repository root.

    .PARAMETER TranscriptPath
        Optional path for a transcript log of the cleanup operation.

    .EXAMPLE
        Clear-TempFile -TranscriptPath ./cleanup.log

        Deletes all temporary files under the repository and logs the actions to
        `cleanup.log`.

    .NOTES
        This command relies on the Logging module for progress output.
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$TranscriptPath
    )

    try {
        if ($TranscriptPath) { Start-Transcript -Path $TranscriptPath -Append | Out-Null }

        $repoRoot = Resolve-Path (Join-Path $PSScriptRoot '../../..')
        Write-STStatus -Message 'Cleaning temporary files...' -Level INFO
        $tmpFiles  = Get-ChildItem -Path $repoRoot -Recurse -Include '*.tmp' -File -ErrorAction SilentlyContinue
        $logFiles  = Get-ChildItem -Path $repoRoot -Recurse -Include '*.log' -File -ErrorAction SilentlyContinue | Where-Object { $_.Length -eq 0 }
        $tmpFiles | Remove-Item -Force -ErrorAction SilentlyContinue
        $logFiles | Remove-Item -Force -ErrorAction SilentlyContinue
        Write-STStatus -Message 'Cleanup complete.' -Level SUCCESS
        return [pscustomobject]@{
            RemovedTmpFileCount = $tmpFiles.Count
            RemovedLogFileCount = $logFiles.Count
        }
    } finally {
        if ($TranscriptPath) { Stop-Transcript | Out-Null }
    }
}
