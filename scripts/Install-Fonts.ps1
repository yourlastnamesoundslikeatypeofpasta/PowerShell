# the purpose of this script is to install fonts
# for all users


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
