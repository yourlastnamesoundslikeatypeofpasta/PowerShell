<#
.SYNOPSIS
    Updates modules referenced by SupportTools.nuspec.
.DESCRIPTION
    Parses the nuspec metadata to determine module dependencies. Each
    dependency is updated using Update-Module. After updating the
    latest installed manifest is validated with Get-AuthenticodeSignature.
    Results are written using Write-STLog.
.EXAMPLE
    ./Update-ModuleDependencies.ps1
#>

Import-Module (Join-Path $PSScriptRoot '..' 'src/Logging/Logging.psd1') -ErrorAction SilentlyContinue

$nuspecPath = Join-Path $PSScriptRoot '..' 'SupportTools.nuspec'
[xml]$nuspec = Get-Content $nuspecPath
$modules = $nuspec.package.metadata.dependencies.dependency | ForEach-Object { $_.id }

foreach ($module in $modules) {
    try {
        Update-Module -Name $module -Force -ErrorAction Stop
        Write-STLog -Message "Updated $module" -Level INFO
    } catch {
        Write-STLog -Message "Failed to update $module: $($_.Exception.Message)" -Level ERROR
        continue
    }

    try {
        $manifest = (Get-Module -ListAvailable -Name $module | Sort-Object Version -Descending | Select-Object -First 1).Path
        if (-not $manifest) {
            Write-STLog -Message "Could not locate $module manifest" -Level ERROR
            continue
        }
        $sig = Get-AuthenticodeSignature -FilePath $manifest
        if ($sig.Status -eq 'Valid') {
            Write-STLog -Message "$module signature valid" -Level INFO
        } else {
            Write-STLog -Message "$module signature invalid: $($sig.StatusMessage)" -Level ERROR
        }
    } catch {
        Write-STLog -Message "Failed to validate $module: $($_.Exception.Message)" -Level ERROR
    }
}
