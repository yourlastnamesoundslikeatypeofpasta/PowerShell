<#
.SYNOPSIS
    Imports the SupportTools suite from the repository source.
.DESCRIPTION
    Loads SupportTools, SharePointTools, ServiceDeskTools and Logging from the
    local `src` folder. The script no longer attempts to download modules from
    any gallery. `SupportToolsVersion` and `Scope` are retained for backward
    compatibility but are ignored.
.PARAMETER SupportToolsVersion
    Ignored parameter kept for compatibility with older automation.
.PARAMETER Scope
    Ignored parameter kept for compatibility with older automation.
.EXAMPLE
    ./Install-SupportTools.ps1
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
    $localPath = Join-Path $PSScriptRoot '..' 'src' $module "$module.psd1"
    if (Test-Path $localPath) {
        Import-Module $localPath -Force -DisableNameChecking
        Write-Warning "Imported $module from $localPath"
    } else {
        Write-Warning "Could not find $module in src"
    }
}
