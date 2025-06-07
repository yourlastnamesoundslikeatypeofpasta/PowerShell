#requires -Version 7.0
<#+
.SYNOPSIS
    Automatically imports SupportTools modules from the src directory.

.DESCRIPTION
    This bootstrap script scans the repository's `src` folder for module
    manifests (*.psd1) or module files (*.psm1) and imports each one.
    It is safe to dot-source multiple times per session as the modules
    are only loaded once.

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

    # Import the Logging module first so logging functions are available
    $loggingPath = Get-ChildItem -Path (Join-Path $srcPath 'Logging') \
        -Filter *.psd1 -File -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $loggingPath) {
        $loggingPath = Get-ChildItem -Path (Join-Path $srcPath 'Logging') \
            -Filter *.psm1 -File -ErrorAction SilentlyContinue | Select-Object -First 1
    }
    if ($loggingPath) {
        try {
            $name = Split-Path $loggingPath.FullName -LeafBase
            if (-not (Get-Module -Name $name)) {
                Import-Module $loggingPath.FullName -Force -ErrorAction Stop
                $loadedModules += $name
                Write-LoaderLog "Loaded module $name"
            }
        } catch {
            Write-Warning "Failed to load Logging module: $($_.Exception.Message)"
        }
    }

    foreach ($dir in Get-ChildItem -Path $srcPath -Directory | Where-Object { $_.Name -ne 'Logging' }) {
        $moduleFile = Get-ChildItem -Path $dir.FullName -Include *.psd1,*.psm1 -File -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($moduleFile) {
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
    }

    if ($loadedModules.Count -gt 0) {
        Write-LoaderLog "Modules loaded: $($loadedModules -join ', ')"
    }
}
