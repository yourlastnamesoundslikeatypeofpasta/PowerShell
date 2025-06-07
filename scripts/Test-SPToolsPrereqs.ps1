<##
.SYNOPSIS
    Validates SharePointTools prerequisites.
.DESCRIPTION
    Checks if the PnP.PowerShell module is installed and optionally installs it from the PowerShell Gallery.
.PARAMETER Install
    If specified, missing modules are installed automatically without prompting.
.EXAMPLE
    ./Test-SPToolsPrereqs.ps1
    Checks for required modules and prompts to install.
.EXAMPLE
    ./Test-SPToolsPrereqs.ps1 -Install
    Installs PnP.PowerShell automatically when missing.
##>
param(
    [switch]$Install
)

Import-Module (Join-Path $PSScriptRoot '..' 'src' 'SharePointTools' 'SharePointTools.psd1') -ErrorAction SilentlyContinue

Test-SPToolsPrereqs -Install:$Install
