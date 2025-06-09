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

    Use-STTranscript -Path $TranscriptPath -ScriptBlock {
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
    }
}
