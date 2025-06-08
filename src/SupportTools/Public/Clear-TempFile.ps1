function Clear-TempFile {
    <#
    .SYNOPSIS
        Removes temporary files from the repository.
    .DESCRIPTION
        Deletes any `.tmp` files and empty `.log` files starting at the
        repository root.
    #>
    [CmdletBinding()]
    param()

    $repoRoot = Resolve-Path (Join-Path $PSScriptRoot '../../..')
    Write-STStatus 'Cleaning temporary files...' -Level INFO
    Get-ChildItem -Path $repoRoot -Recurse -Include '*.tmp' -File -ErrorAction SilentlyContinue |
        Remove-Item -Force -ErrorAction SilentlyContinue
    Get-ChildItem -Path $repoRoot -Recurse -Include '*.log' -File -ErrorAction SilentlyContinue |
        Where-Object { $_.Length -eq 0 } | Remove-Item -Force -ErrorAction SilentlyContinue
    Write-STStatus 'Cleanup complete.' -Level SUCCESS
}
