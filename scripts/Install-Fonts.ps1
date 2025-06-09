#
# <#
# .SYNOPSIS
# Install fonts for all users.
#
# .DESCRIPTION
# Provides helper functions for enumerating fonts in a folder and copying
# them to the system fonts directory. Registry entries are created so the
# fonts are available to all users. Administrator rights are required.
# #>

Import-Module (Join-Path $PSScriptRoot '..' 'src/Logging/Logging.psd1') -Force -ErrorAction SilentlyContinue

function Main {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$FontFolder
    )

    Write-STStatus "Installing fonts from $FontFolder..." -Level INFO
    if (-not ([bool](New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator))) {
        throw 'Administrator rights are required to install fonts.'
    }

    $fonts = Get-Fonts -FontFolder $FontFolder
    Install-Fonts -Fonts $fonts
    Write-STStatus -Message 'Font installation complete.' -Level SUCCESS
}

function Get-Fonts {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $FontFolder
    )
    $FontItem = Get-Item -Path $FontFolder
    $FontList = Get-ChildItem -Path "$FontItem\*" -Include ('*.fon','*.otf','*.ttc','*.ttf')

    return $FontList
}

function Install-Fonts {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [array]
        $Fonts
    )

    $repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
    $defaultsFile = Join-Path $repoRoot 'config/config.psd1'
    $STDefaults = Get-STConfig -Path $defaultsFile
    $fontsDir = Get-STConfigValue -Config $STDefaults -Key 'FontsDir'
    $fontsReg = Get-STConfigValue -Config $STDefaults -Key 'FontsRegPath'

    foreach ($font in $Fonts)
    {
        $fontName = $font.Name
        Copy-Item -Path $font.FullName -Destination $fontsDir -Force
        New-ItemProperty -Name $font.BaseName -Path $fontsReg -PropertyType string -Value $font.Name -Force
    }
    
}
