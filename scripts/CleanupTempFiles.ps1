<#
.SYNOPSIS
    Removes temporary files from the repository.
.DESCRIPTION
    Searches recursively from the repository root and deletes files with a `.tmp` extension and any empty `.log` files.
.EXAMPLE
    ./CleanupTempFiles.ps1
#>

Write-Host 'Cleaning temporary files...' -ForegroundColor Cyan
$repoRoot = Join-Path $PSScriptRoot '..'
Get-ChildItem -Path $repoRoot -Recurse -Include '*.tmp' -File -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
Get-ChildItem -Path $repoRoot -Recurse -Include '*.log' -File -ErrorAction SilentlyContinue | Where-Object { $_.Length -eq 0 } | Remove-Item -Force -ErrorAction SilentlyContinue
Write-Host 'Cleanup complete.' -ForegroundColor Green
