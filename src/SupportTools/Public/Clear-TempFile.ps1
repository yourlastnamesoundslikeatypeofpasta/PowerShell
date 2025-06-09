function Clear-TempFile {
    <#
    .SYNOPSIS
        Removes temporary files from the repository.
    .DESCRIPTION
        Deletes any `.tmp` files and empty `.log` files starting at the
        repository root.
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
        try {
            $tmpFiles  = Get-ChildItem -Path $repoRoot -Recurse -Include '*.tmp' -File -ErrorAction Stop
            $logFiles  = Get-ChildItem -Path $repoRoot -Recurse -Include '*.log' -File -ErrorAction Stop | Where-Object { $_.Length -eq 0 }
        } catch {
            Write-Error $_.Exception.Message
            throw
        }

        try {
            $tmpFiles | Remove-Item -Force -ErrorAction Stop
            $logFiles | Remove-Item -Force -ErrorAction Stop
        } catch {
            Write-Error $_.Exception.Message
            throw
        }

        Write-STStatus -Message 'Cleanup complete.' -Level SUCCESS
        return [pscustomobject]@{
            RemovedTmpFileCount = $tmpFiles.Count
            RemovedLogFileCount = $logFiles.Count
        }
    } finally {
        if ($TranscriptPath) { Stop-Transcript | Out-Null }
    }
}
