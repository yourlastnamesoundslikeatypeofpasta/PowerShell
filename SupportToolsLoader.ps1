#requires -Version 7.0
<#+
.SYNOPSIS
    Automatically imports SupportTools modules from the src directory.

.DESCRIPTION
    This bootstrap script scans the repository's `src` folder recursively for
    module manifests (*.psd1) and imports each one. It is safe to dot-source
    multiple times per session as the modules are only loaded once.

.EXAMPLE
    . ./SupportToolsLoader.ps1
#>

if (-not $script:SupportToolsLoaderLoaded) {
    $script:SupportToolsLoaderLoaded = $true

    function Write-LoaderLog {
        param([string]$Message)
        if (Get-Command Write-STStatus -ErrorAction SilentlyContinue) {
            Write-STStatus -Message $Message -Level SUB -Log
        } else {
            Write-Host $Message
        }
    }

    $repoRoot = $PSScriptRoot
    $srcPath  = Join-Path $repoRoot 'src'
    if (-not (Test-Path $srcPath)) {
        Write-Warning "Source folder '$srcPath' not found."
        return
    }

    $loadedModules = @()

    # Find all module manifests under src
    $moduleFiles = Get-ChildItem -Path $srcPath -Recurse -Filter *.psd1 -File | Sort-Object FullName

    foreach ($moduleFile in $moduleFiles) {
        try {
            $name = Split-Path $moduleFile.FullName -LeafBase
            if (-not (Get-Module -Name $name)) {
                Import-Module $moduleFile.FullName -Force -ErrorAction Stop
                $loadedModules += $name
                Write-LoaderLog "Loaded module $name"
            }
        } catch {
            Write-Warning "Failed to import module from $($moduleFile.FullName): $($_.Exception.Message)"
        }
    }

    if ($loadedModules.Count -gt 0) {
        Write-LoaderLog "Modules loaded: $($loadedModules -join ', ')"
    }
}
