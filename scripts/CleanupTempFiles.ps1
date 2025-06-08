<#
.SYNOPSIS
    Removes temporary files from the repository.
.DESCRIPTION
    Searches recursively from the repository root and deletes files with a `.tmp` extension and any empty `.log` files.
.EXAMPLE
    ./CleanupTempFiles.ps1
#>

param()
Import-Module (Join-Path $PSScriptRoot '..' 'src/SupportTools/SupportTools.psd1') -Force
Clear-TempFile
