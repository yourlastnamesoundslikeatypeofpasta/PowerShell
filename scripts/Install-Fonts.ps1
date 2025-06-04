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


function Main {
    
    
}

function Get-Fonts {

    param (
        [string]
        $FontFolder
    )
    $FontItem = Get-Item -Path $FontFolder
    $FontList = Get-ChildItem -Path "$FontItem\*" -Include ('*.fon','*.otf','*.ttc','*.ttf')

    return $FontList
}

function Install-Fonts {
    param (
        [array]
        $Fonts
    )

    foreach ($font in $Fonts)
    {
        $fontName = $font.Name
        Copy-Item -Path $Font.FullName -Destination "C:\Windows\Fonts" 
        New-ItemProperty -Name $font.BaseName -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -PropertyType string -Value $Font.name   
    }
    
}
