<#
.SYNOPSIS
    Launch an interactive menu to run common SupportTools tasks.
.DESCRIPTION
    Provides a simple CLI menu so colleagues can choose actions
    without typing commands. Each option invokes the related
    SupportTools function.
.EXAMPLE
    ./SupportToolsMenu.ps1
#>

Import-Module (Join-Path $PSScriptRoot '..' 'src/Logging/Logging.psd1') -ErrorAction SilentlyContinue
Import-Module (Join-Path $PSScriptRoot '..' 'src/SupportTools/SupportTools.psd1') -ErrorAction SilentlyContinue

function Show-Menu {
    Write-STDivider 'SupportTools Menu' -Style heavy
    Write-Host '1. Add users to group'
    Write-Host '2. Cleanup archive folder'
    Write-Host 'Q. Quit'
}

while ($true) {
    Show-Menu
    $choice = Read-Host 'Select an option'
    switch ($choice) {
        '1' {
            Write-STStatus 'Running Add-UserToGroup...' -Level INFO
            Add-UserToGroup
        }
        '2' {
            Write-STStatus 'Running Clear-ArchiveFolder...' -Level INFO
            Clear-ArchiveFolder
        }
        'q' { break }
        'Q' { break }
        default {
            Write-STStatus 'Invalid choice. Try again.' -Level WARN
        }
    }
    Write-Host
}

Write-STClosing
