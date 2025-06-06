#
function PostInstallScript {
# <#
# .SYNOPSIS
# Automate Windows 10 setup while in audit mode.
#
# .DESCRIPTION
# Contains helper functions to install applications, copy files, deploy
# agents, set power options and join a computer to the domain. Intended
# for use during post installation configuration while running in audit
# mode.
# #>


# Functions listed here

function MSStoreAppInstallerUpdate {
    Start-Process ms-windows-store://pdp/?ProductId=9NBLGGH4NNS1
    if (!$LASTEXITCODE)
    {
        Write-Information -MessageData "Opened Microsoft Store App Installer"
    }
    else 
    {
        Write-Error -MessageData "FAILED opening Microsoft Store"
    }
}


function Install-Chrome {
    Write-Host 'Installing: Google Chrome'

    $package_id = 'Google.Chrome'
    winget install -e --id $package_id --scope machine --accept-source-agreements --silent

    # validate install
    if (!$LASTEXITCODE) {
        Write-Host 'Google Chrome: Installed'
    } 
    else {
        Write-Error 'GoogleChromeNotInstalled'
    }
}


function Install-AdobeAcrobatReader {
    Write-Host 'Installing: Adobe Acrobat Reader'

    $package_id = 'Adobe.Acrobat.Reader.64-bit'
    winget install -e --id $package_id --scope machine --accept-source-agreements --silent

    # validate install
    if (!$LASTEXITCODE) {
        Write-Host 'Adobe Acrobat Reader: Installed'
    } 
    else {
        Write-Error 'AdobeAcrobatReaderNotInstalled'
    }
}


function Install-ExcelMobile {
    Write-Host 'Installing: Excel Mobile'

    $package_id = '9WZDNCRFJBH3'
    winget install -e --id $package_id --scope machine --accept-source-agreements --silent

    # validate install
    if (!$LASTEXITCODE)
    {
        Write-Host 'Excel Mobile: Installed'
    }
    else {
        Write-Error 'ExcelMobileNotInstalled'
    }
}


function Enable-NetFramework {
    Write-Host ".NET 3.5 Framework: Enabling..."
    Enable-WindowsOptionalFeature -Online -FeatureName "NetFx3" -All -NoRestart -ErrorAction Stop > $null

    # validate install
    if (!$LASTEXITCODE) {
        Write-Host '.NET Framework 3.5: ENABLED'
    } 
    else {
        Write-Error '.NETFramework3.5NotEnabled'
    }
}


function Get-ComputerName
{
    # pipe the string returned to Rename-Computer
    # EX: Get-ComputerName | 
    $unconfirmed = $true
    while ($unconfirmed)
    {
        $computerNameOne = Read-Host -Prompt 'What would you like to name this computer?'

        $computerNameTwo = Read-Host -Prompt 'Re-enter the computer name previously entered'

        if ($computerNameOne -eq $computerNameTwo)
        {
            $unconfirmed = $false
        }
        else 
        {
            Write-Warning -Message "Computer names do not match up. Try again."
        }
    }
    $computerNameOne
}


function Get-DriveLetter {
        # get the correct drive letter
        $driveLetters = @("D", "E", "F", "G")
        foreach ($driverLetter in $driveLetters)
        {
            $drivePath = "$($driverLetter):\"
            $isDrivePathValid = Test-Path $drivePath
            if ($isDrivePathValid)
            {
                return $drivePath
            }
        }
}


function Get-AgentPath {
    param (
        [string] $Agent,
        [switch] $USB,
        [switch] $Local
    )

    $driveLetter = Get-DriveLetter
    if ($USB)
    {
    
        if ($Agent -eq "[REDACTED]")
        {
            $agentPath = "$($driveLetter)assets\agents\[REDACTED]\[REDACTED].exe"
        }
        elseif ($Agent -eq "[REDACTED]") {
            $agentPath = "$($driveLetter)assets\agents\[REDACTED]\[REDACTED].msi"
        }
        elseif ($Agent -eq "[REDACTED]") {
            $agentPath = "$($driveLetter)assets\agents\[REDACTED]\[REDACTED].exe"
        }
        elseif ($Agent -eq "[REDACTED]") {
            $agentPath = "$($driveLetter)assets\agents\[REDACTED]\[REDACTED].exe"
        }
    }

    if ($Local)
    {
        if ($Agent -eq "[REDACTED]")
        {
            $agentPath = ".\assets\agents\[REDACTED]\[REDACTED].exe"
        }
        elseif ($Agent -eq "[REDACTED]") {
            $agentPath = "$.\assets\agents\[REDACTED]\[REDACTED].msi"
        }
        elseif ($Agent -eq "Sysmon") {
            $agentPath = ".\assets\agents\SysmonAgent\Sysmon64.exe"
        }
        elseif ($Agent -eq "[REDACTED]") {
            $agentPath = ".\assets\agents\[REDACTED]\[REDACTED].exe"
        }
    }

    return $agentPath

}

function Install-[REDACTED]
{
    param (
        [switch] $USB,
        [switch] $Local
    )

    if ($USB)
    {
        # copy key.txt to clipboard
        $driveLetter = Get-DriveLetter
        Get-Content "$($driveLetter)assets\agents\[REDACTED]\key.txt" | Set-Clipboard
    }

    if ($Local)
    {
        Get-Content ".\assets\agents\[REDACTED]\key.txt" | Set-Clipboard
    }

    Write-Information -MessageData "Key copied to clipboard..." -InformationAction Continue

    # open [REDACTED]
    $Path = Get-AgentPath -Agent "[REDACTED]" -USB
    Start-Process $Path 
}


function Install-[REDACTED]
{
    # open [REDACTED]
    $Path = Get-AgentPath -Agent "[REDACTED]" -USB
    Start-Process $Path
}

function Install-[REDACTED]
{
    # Install Sysmon64.exe
    $Path = Get-AgentPath -Agent "[REDACTED]" -USB

    & $Path -i -accepteula
}

function Install-[REDACTED] 
{
    # open ManageEngineAgentInstaller
    $Path = Get-AgentPath -Agent "[REDACTED]" -USB
    Start-Process $Path
}

function Copy-Files
{
    param (
        [switch] $USB,
        [switch] $Local
    )

    if ($USB)
    {
    # Copy admin shortcut files from DesktopTools to public desktop
    $driveLetter = Get-DriveLetter
    $adminShortcuts = Get-ChildItem "$($driveLetter)assets\Tools\DesktopTools" 
    }

    if ($Local)
    {
        $adminShortcuts = Get-ChildItem ".\assets\Tools\DesktopTools" 
    }


    foreach ($shortcut in $adminShortcuts)
    {
        Copy-Item -Path $shortcut.Fullname -Destination "C:\Users\Public\Desktop\"
    }



    # Copy printer drivers to public desktop
    if ($USB)
    {
        Copy-Item -Path "$($driveLetter)assets\PrinterDrivers" -Destination "C:\Users\Public\Desktop" -Recurse
    }

    if ($Local)
    {
        Copy-Item -Path ".\assets\PrinterDrivers" -Destination "C:\Users\Public\Desktop" -Recurse
    }
}


function Set-PowerPlan {
    # set power plan to high performance
    $high_performance_guid = '8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c'
    $balanced_guid = '381b4222-f694-41f0-9685-ff5bb260df2e'
    $power_saver_guid = 'a1841308-3541-4fab-bc81-f71556f20b4a'

    # set power plan to high performance
    Write-Host "Setting Power Plan: High Performance"
    powercfg.exe /S $high_performance_guid
    if (!$LASTEXITCODE) {
        Write-Host "Set Power Plan: High Performance"
    }
    else {
        Write-Error 'PowerPlanHighPerformanceNotSet'
    }

    # remove balanced power plan
    Write-Host "Deleting Power Plan: Balanced"
    powercfg.exe /D $balanced_guid
    if (!$LASTEXITCODE) {
        Write-Host "Deleted Power Plan: Balanced"
    }
    else {
        Write-Error 'PowerPlanBalancedNotDeleted'
    }

    # remove power saver power plan
    Write-Host "Deleting Power Plan: Power Saver"
    powercfg.exe /D $power_saver_guid
    if (!$LASTEXITCODE) {
        Write-Host "Deleted Power Plan: Power Saver"
    }
    else {
        Write-Error 'PowerPlanPowerSaverNotDeleted'
    }
}

function Main
{
    # install agents
    Write-Information -MessageData "Executing Agent Installers" -InformationAction Continue
    Install-[REDACTED] -USB
    Install-[REDACTED] 
    Install-Sysmon 
    Install-[REDACTED]
    Read-Host -Prompt "Press enter to continue..." 

    # Install winget applications
    Write-Information -MessageData "Update App Installer..."
    MSStoreAppInstallerUpdate
    Read-Host -Prompt "Press enter to continue..."
    
    # install applications
    Write-Information -MessageData "Installing Chrome, Excel Mobile, and Adobe Acrobat Reader..." -InformationAction Continue
    Install-Chrome
    Install-ExcelMobile
    Install-AdobeAcrobatReader

    # configure
    Write-Information -MessageData "Enabling .NET Frame 3.5..." -InformationAction Continue
    Enable-NetFramework

    # copy files
    Copy-Files -USB

    Write-Information -MessageData "Setting Power Plan..." -InformationAction Continue
    Set-PowerPlan

    # name computer
    Write-Information -MessageData "Renaming Computer..." -InformationAction Continue
    $newComputerName = Get-ComputerName
    Rename-Computer -NewName $newComputerName -Force

    # add computer to domain
    Write-Warning "Adding Computer to domain...Press [CTRL] + [C] to abort..."
    Add-Computer -NewName $newComputerName -DomainName "myus.local" -DomainCredential (Get-Credential) -Force

    Write-Information -MessageData "Restart computer to apply changes..."

}

}
