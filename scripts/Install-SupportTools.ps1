<#
.SYNOPSIS
    Installs the SupportTools suite from the PowerShell Gallery.
.DESCRIPTION
    Downloads SupportTools, SharePointTools, ServiceDeskTools and Logging from the gallery.
    If a version is specified for SupportTools it will be pinned using -RequiredVersion.
.PARAMETER SupportToolsVersion
    Version of SupportTools to install. Defaults to the latest available version.
.PARAMETER Scope
    Scope to install the modules. Defaults to CurrentUser.
.EXAMPLE
    ./Install-SupportTools.ps1 -SupportToolsVersion 1.0.4
#>
param(
    [string]$SupportToolsVersion,
    [ValidateSet('CurrentUser','AllUsers')]
    [string]$Scope = 'CurrentUser'
)

$modules = @('Logging','SharePointTools','ServiceDeskTools','SupportTools')

foreach ($module in $modules) {
    if ($module -eq 'SupportTools' -and $SupportToolsVersion) {
        Install-Module -Name $module -RequiredVersion $SupportToolsVersion -Scope $Scope -Force -AllowClobber
    } else {
        Install-Module -Name $module -Scope $Scope -Force -AllowClobber
    }
}
