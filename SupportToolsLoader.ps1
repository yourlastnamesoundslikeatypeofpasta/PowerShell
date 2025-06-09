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

function Import-SupportToolsModules {
    [CmdletBinding()]
    param(
        [string]$Path = (Join-Path $PSScriptRoot 'src'),
        [string[]]$Exclude = @(),
        [switch]$Force
    )

    if (-not $script:SupportToolsLoaderLoaded) {
        $script:SupportToolsLoaderLoaded = $true
    }

    try {
        Import-Module (Join-Path $PSScriptRoot 'src/OutTools/OutTools.psd1') -Force -ErrorAction Stop -DisableNameChecking
    } catch {
        Write-STStatus -Message "Failed to import OutTools module: $($_.Exception.Message)" -Level WARN
    }

    function Write-LoaderLog {
        param([string]$Message)
        if (Get-Command Out-STStatus -ErrorAction SilentlyContinue) {
            Out-STStatus -Message $Message -Level SUB -Log
        }
    }

    if (-not (Test-Path $Path)) {
        Out-STStatus -Message "Source folder '$Path' not found. Ensure the repository is cloned correctly." -Level ERROR -Log
        return
    }

    if (-not $Force -and $script:SupportToolsModuleFiles) {
        $moduleFiles = $script:SupportToolsModuleFiles
    } else {
        $moduleFiles = Get-ChildItem -Path $Path -Recurse -Filter *.psd1 -File | Sort-Object FullName
        $script:SupportToolsModuleFiles = $moduleFiles
    }

    $loadedModules = [System.Collections.Generic.List[object]]::new()

    foreach ($moduleFile in $moduleFiles) {
        $name = Split-Path $moduleFile.FullName -LeafBase
        if ($Exclude -contains $name) { continue }
        try {
            if (-not (Get-Module -Name $name)) {
                Import-Module $moduleFile.FullName -Force -ErrorAction Stop -DisableNameChecking
                $loadedModules.Add($name)
                Write-LoaderLog "Loaded module $name"
                $bannerFunc = "Show-$name`Banner"
                if (Get-Command $bannerFunc -ErrorAction SilentlyContinue) {
                    & $bannerFunc | Out-STBanner
                }
            }
        } catch {
            Out-STStatus -Message "Failed to import module from $($moduleFile.FullName): $($_.Exception.Message)" -Level ERROR
            Write-STLog -Message "Module import failed: $($moduleFile.FullName) - $($_.Exception.Message)" -Level Error
        }
    }

    if ($loadedModules.Count -gt 0) {
        Write-LoaderLog "Modules loaded: $($loadedModules -join ', ')"
    }
}

if ($MyInvocation.InvocationName -eq '.') {
    Import-SupportToolsModules
}
