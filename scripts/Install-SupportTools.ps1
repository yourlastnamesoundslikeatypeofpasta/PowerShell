<#
.SYNOPSIS
    Installs the SupportTools suite from the PowerShell Gallery.
.DESCRIPTION
    Downloads SupportTools, SharePointTools, ServiceDeskTools and Logging from the gallery.
    If a version is specified for SupportTools it will be pinned using -RequiredVersion.
    If the gallery is unavailable the modules are imported from the local src folder.
.PARAMETER SupportToolsVersion
    Version of SupportTools to install. Defaults to the latest available version.
.PARAMETER Scope
    Scope to install the modules. Defaults to CurrentUser.
.EXAMPLE
    ./Install-SupportTools.ps1 -SupportToolsVersion 1.3.0
#>
param(
    [string]$SupportToolsVersion,
    [ValidateSet('CurrentUser','AllUsers')]
    [string]$Scope = 'CurrentUser'
)

$modules = @(
    'Logging',
    'Telemetry',
    'SharePointTools',
    'ServiceDeskTools',
    'SupportTools'
)

Import-Module (Join-Path $PSScriptRoot '..' 'src/Logging/Logging.psd1') -Force -ErrorAction SilentlyContinue -DisableNameChecking

foreach ($module in $modules) {
    try {
        if ($module -eq 'SupportTools' -and $SupportToolsVersion) {
            Install-Module -Name $module -RequiredVersion $SupportToolsVersion -Scope $Scope -Force -AllowClobber -ErrorAction Stop
        } else {
            Install-Module -Name $module -Scope $Scope -Force -AllowClobber -ErrorAction Stop
        }
    } catch {
        Write-Warning "Failed to install $module from gallery: $($_.Exception.Message)"
        $localPath = Join-Path $PSScriptRoot '..' 'src' $module "$module.psd1"
        if (Test-Path $localPath) {
            Import-Module $localPath -Force -DisableNameChecking
            Write-Warning "Imported $module from $localPath"
        } else {
            Write-Warning "Could not find $module in src"
        }
    }
}
