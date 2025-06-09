<#
.SYNOPSIS
    Browse and execute scripts from an interactive menu.
.DESCRIPTION
    Lists all .ps1 files in the current folder and allows
    the user to select one to run. Useful for discovering
    scripts without memorizing each filename.
.EXAMPLE
    ./ScriptLauncher.ps1
#>

Import-Module (Join-Path $PSScriptRoot '..' 'src/Logging/Logging.psd1') -Force -ErrorAction SilentlyContinue

function Get-ScriptInfo {
    param([string]$Path)
    $lines = Get-Content $Path -First 10
    $synopsis = $lines | Where-Object { $_ -match '\.SYNOPSIS' } |
        ForEach-Object { ($_ -replace '.*\.SYNOPSIS', '').Trim() }
    if (-not $synopsis) { $synopsis = Split-Path $Path -Leaf }
    [pscustomobject]@{ Path = $Path; Name = Split-Path $Path -Leaf; Synopsis = $synopsis }
}

$scriptFiles = Get-ChildItem -Path $PSScriptRoot -Filter '*.ps1' |
    Where-Object { $_.Name -notin 'ScriptLauncher.ps1', 'SupportToolsMenu.ps1' } |
    ForEach-Object { Get-ScriptInfo $_.FullName }

function Show-Menu {
    Write-STDivider -Title 'Available Scripts' -Style light
    for ($i = 0; $i -lt $scriptFiles.Count; $i++) {
        $num = $i + 1
        Write-STStatus "$num. $($scriptFiles[$i].Name) - $($scriptFiles[$i].Synopsis)" -Level INFO
    }
    Write-STStatus -Message 'Q. Quit' -Level INFO
}

while ($true) {
    Show-Menu
    $choice = Read-Host 'Select an option'
    if ($choice -match '^[Qq]$') { break }
    $index = [int]$choice - 1
    if ($index -ge 0 -and $index -lt $scriptFiles.Count) {
        & $scriptFiles[$index].Path
    } else {
        Write-STStatus -Message 'Invalid choice. Try again.' -Level WARN
    }
    Write-STStatus -Message '' -Level INFO
}

Write-STClosing
