<#
.SYNOPSIS
    Imports the SupportTools suite from the repository source.
.DESCRIPTION
    Loads SupportTools, IncidentResponseTools, SharePointTools, ServiceDeskTools
    and Logging from the local `src` folder. The script no longer attempts to
    download modules from any gallery. `SupportToolsVersion` and `Scope` are
    retained for backward compatibility but are ignored.
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

# Load Logging first so status functions are available
# Import-Module (Join-Path $PSScriptRoot '..' 'src/Logging/Logging.psd1') -Force -ErrorAction SilentlyContinue -DisableNameChecking

$modules = @(
    'Telemetry',
    'SharePointTools',
    'ServiceDeskTools',
    'SupportTools',
    'IncidentResponseTools'
)

Write-Host '$ ./scripts/Install-SupportTools.ps1'

foreach ($module in $modules) {
    $localPath = Join-Path $PSScriptRoot '..' 'src' $module "$module.psd1"
    if (Test-Path $localPath) {
        Write-Host "Importing $module..."
        Import-Module $localPath -Force -DisableNameChecking
        Write-Host "Imported $module from $localPath"
    } else {
        Write-Host "Could not find $module in src"
    }
}

Write-Host 'Module import complete'
