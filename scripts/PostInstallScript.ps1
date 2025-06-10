#
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

Import-Module (Join-Path $PSScriptRoot '..' 'src/Logging/Logging.psd1') -Force -ErrorAction SilentlyContinue
$os = $PSVersionTable.OS
if ($MyInvocation.InvocationName -ne '.' -and ($os -notmatch 'Windows')) {
    Write-STStatus -Message 'PostInstallScript can only run on Windows.' -Level ERROR
    exit 1
}
$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
$defaultsFile = Join-Path $repoRoot 'config/config.psd1'
$STDefaults = Get-STConfig -Path $defaultsFile
$publicDesktop = Get-STConfigValue -Config $STDefaults -Key 'PublicDesktop'

function Assert-WingetInstalled {
    [CmdletBinding()]
    param()
    <#
    .SYNOPSIS
        Ensures the winget command is available.
    #>
    $winget = Get-Command winget -ErrorAction SilentlyContinue
    if (-not $winget) {
        Write-STStatus -Message 'winget not found. Install App Installer first.' -Level ERROR
        throw 'WingetNotFound'
    }
    Write-STStatus -Message 'winget detected.' -Level SUCCESS
}

function MSStoreAppInstallerUpdate {
    [CmdletBinding()]
    param()
    <#
    .SYNOPSIS
        Opens the Microsoft Store page for the App Installer.
    .DESCRIPTION
        Launches the Store page to allow the user to update the App Installer
        application.
    #>
    Start-Process ms-windows-store://pdp/?ProductId=9NBLGGH4NNS1
    if (!$LASTEXITCODE)
    {
        Write-STStatus -Message 'Opened Microsoft Store App Installer' -Level SUCCESS
    }
    else
    {
        Write-STStatus -Message 'FAILED opening Microsoft Store' -Level ERROR
    }
}


function Install-Chrome {
    [CmdletBinding()]
    param()
    <#
    .SYNOPSIS
        Installs the Google Chrome browser using winget.
    #>
    Write-STStatus -Message 'Installing: Google Chrome' -Level INFO

    $PackageId = 'Google.Chrome'
    winget install -e --id $PackageId --scope machine --accept-source-agreements --silent

    # validate install
    if (!$LASTEXITCODE) {
        Write-STStatus -Message 'Google Chrome: Installed' -Level SUCCESS
    } 
    else {
        Write-Error 'GoogleChromeNotInstalled'
    }
}


function Install-AdobeAcrobatReader {
    [CmdletBinding()]
    param()
    <#
    .SYNOPSIS
        Installs Adobe Acrobat Reader via winget.
    #>
    Write-STStatus -Message 'Installing: Adobe Acrobat Reader' -Level INFO

    $PackageId = 'Adobe.Acrobat.Reader.64-bit'
    winget install -e --id $PackageId --scope machine --accept-source-agreements --silent

    # validate install
    if (!$LASTEXITCODE) {
        Write-STStatus -Message 'Adobe Acrobat Reader: Installed' -Level SUCCESS
    } 
    else {
        Write-Error 'AdobeAcrobatReaderNotInstalled'
    }
}


function Install-ExcelMobile {
    [CmdletBinding()]
    param()
    <#
    .SYNOPSIS
        Installs the Excel Mobile application via winget.
    #>
    Write-STStatus -Message 'Installing: Excel Mobile' -Level INFO

    $PackageId = '9WZDNCRFJBH3'
    winget install -e --id $PackageId --scope machine --accept-source-agreements --silent

    # validate install
    if (!$LASTEXITCODE)
    {
        Write-STStatus -Message 'Excel Mobile: Installed' -Level SUCCESS
    }
    else {
        Write-Error 'ExcelMobileNotInstalled'
    }
}


function Enable-NetFramework {
    [CmdletBinding()]
    param()
    <#
    .SYNOPSIS
        Enables the .NET Framework 3.5 feature.
    #>
    Write-STStatus -Message '.NET 3.5 Framework: Enabling...' -Level INFO
    Enable-WindowsOptionalFeature -Online -FeatureName "NetFx3" -All -NoRestart -ErrorAction Stop > $null

    # validate install
    if (!$LASTEXITCODE) {
        Write-STStatus -Message '.NET Framework 3.5: ENABLED' -Level SUCCESS
    } 
    else {
        Write-Error '.NETFramework3.5NotEnabled'
    }
}


function Get-ComputerName {
    [CmdletBinding()]
    param()
    <#
    .SYNOPSIS
        Prompts the user for a computer name until the value is confirmed.
    .OUTPUTS
        System.String
    #>
    # pipe the string returned to Rename-Computer
    # EX: Get-ComputerName | 
    $Unconfirmed = $true
    while ($Unconfirmed)
    {
        $ComputerNameOne = Read-Host -Prompt 'What would you like to name this computer?'

        $ComputerNameTwo = Read-Host -Prompt 'Re-enter the computer name previously entered'

        if ($ComputerNameOne -eq $ComputerNameTwo)
        {
            $Unconfirmed = $false
        }
        else
        {
            Write-STStatus -Message 'Computer names do not match up. Try again.' -Level WARN
        }
    }
    $ComputerNameOne
}


function Get-DriveLetter {
    [CmdletBinding()]
    param()
    <#
    .SYNOPSIS
        Returns the drive letter containing installation media.
    .OUTPUTS
        System.String
    #>
        # get the correct drive letter
        $DriveLetters = @("D", "E", "F", "G")
        foreach ($DriverLetter in $DriveLetters)
        {
            $DrivePath = "$($DriverLetter):\"
            $IsDrivePathValid = Test-Path $DrivePath
            if ($IsDrivePathValid)
            {
                return $DrivePath
            }
        }
}


function Get-AgentPath {
    [CmdletBinding()]
    <#
    .SYNOPSIS
        Retrieves the installation path for a specified agent.
    .PARAMETER Agent
        Name of the agent to locate.
    .PARAMETER USB
        Look for the agent on attached USB media.
    .PARAMETER Local
        Look for the agent in the local assets folder.
    .OUTPUTS
        System.String
    #>
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Agent,
        [switch]$USB,
        [switch]$Local
    )

    $DriveLetter = Get-DriveLetter
    if ($USB)
    {
    
        if ($Agent -eq "[REDACTED]")
        {
            $AgentPath = "$($DriveLetter)assets\agents\[REDACTED]\[REDACTED].exe"
        }
        elseif ($Agent -eq "[REDACTED]") {
            $AgentPath = "$($DriveLetter)assets\agents\[REDACTED]\[REDACTED].msi"
        }
        elseif ($Agent -eq "[REDACTED]") {
            $AgentPath = "$($DriveLetter)assets\agents\[REDACTED]\[REDACTED].exe"
        }
        elseif ($Agent -eq "[REDACTED]") {
            $AgentPath = "$($DriveLetter)assets\agents\[REDACTED]\[REDACTED].exe"
        }
    }

    if ($Local)
    {
        if ($Agent -eq "[REDACTED]")
        {
            $AgentPath = ".\assets\agents\[REDACTED]\[REDACTED].exe"
        }
        elseif ($Agent -eq "[REDACTED]") {
            $AgentPath = "$.\assets\agents\[REDACTED]\[REDACTED].msi"
        }
        elseif ($Agent -eq "Sysmon") {
            $AgentPath = ".\assets\agents\SysmonAgent\Sysmon64.exe"
        }
        elseif ($Agent -eq "[REDACTED]") {
            $AgentPath = ".\assets\agents\[REDACTED]\[REDACTED].exe"
        }
    }

    return $AgentPath

}

function Install-[REDACTED] {
    [CmdletBinding()]
    <#
    .SYNOPSIS
        Copies a license key to the clipboard and launches the installer.
    #>
    param (
        [switch] $USB,
        [switch] $Local
    )

    if ($USB)
    {
        # copy key.txt to clipboard
        $DriveLetter = Get-DriveLetter
        Get-Content "$($DriveLetter)assets\agents\[REDACTED]\key.txt" | Set-Clipboard
    }

    if ($Local)
    {
        Get-Content ".\assets\agents\[REDACTED]\key.txt" | Set-Clipboard
    }

    Write-STStatus -Message 'Key copied to clipboard...' -Level SUCCESS

    # open [REDACTED]
    $Path = Get-AgentPath -Agent "[REDACTED]" -USB
    Start-Process $Path 
}


function Install-[REDACTED] {
    [CmdletBinding()]
    <#
    .SYNOPSIS
        Launches the [REDACTED] installer from USB media.
    #>
    # open [REDACTED]
    $Path = Get-AgentPath -Agent "[REDACTED]" -USB
    Start-Process $Path
}

function Install-[REDACTED] {
    [CmdletBinding()]
    <#
    .SYNOPSIS
        Installs Sysmon using predefined arguments.
    #>
    # Install Sysmon64.exe
    $Path = Get-AgentPath -Agent "[REDACTED]" -USB

    & $Path -i -accepteula
}

function Install-[REDACTED] {
    [CmdletBinding()]
    <#
    .SYNOPSIS
        Launches the ManageEngine agent installer.
    #>
    # open ManageEngineAgentInstaller
    $Path = Get-AgentPath -Agent "[REDACTED]" -USB
    Start-Process $Path
}

function Copy-Files {
    [CmdletBinding()]
    <#
    .SYNOPSIS
        Copies administration shortcuts from installation media to the public desktop.
    .PARAMETER USB
        Indicates the files should be copied from a USB drive.
    .PARAMETER Local
        Indicates the files should be copied from the local assets folder.
    #>
    param (
        [switch] $USB,
        [switch] $Local
    )

    if ($USB)
    {
    # Copy admin shortcut files from DesktopTools to public desktop
    $DriveLetter = Get-DriveLetter
    $AdminShortcuts = Get-ChildItem "$($DriveLetter)assets\Tools\DesktopTools" 
    }

    if ($Local)
    {
        $AdminShortcuts = Get-ChildItem ".\assets\Tools\DesktopTools" 
    }


    foreach ($shortcut in $AdminShortcuts)
    {
        Copy-Item -Path $shortcut.Fullname -Destination $publicDesktop
    }



    # Copy printer drivers to public desktop
    if ($USB)
    {
        Copy-Item -Path "$($DriveLetter)assets\PrinterDrivers" -Destination $publicDesktop -Recurse
    }

    if ($Local)
    {
        Copy-Item -Path ".\assets\PrinterDrivers" -Destination $publicDesktop -Recurse
    }
}


function Set-PowerPlan {
    [CmdletBinding()]
    param()
    <#
    .SYNOPSIS
        Configures the system power plan for performance.
    .DESCRIPTION
        Sets High Performance as the active plan and removes the Balanced and
        Power Saver plans.
    #>
    $HighPerformanceGuid = '8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c'
    $BalancedGuid = '381b4222-f694-41f0-9685-ff5bb260df2e'
    $PowerSaverGuid = 'a1841308-3541-4fab-bc81-f71556f20b4a'

    # set power plan to high performance
    Write-STStatus -Message 'Setting Power Plan: High Performance' -Level INFO
    powercfg.exe /S $HighPerformanceGuid
    if (!$LASTEXITCODE) {
        Write-STStatus -Message 'Set Power Plan: High Performance' -Level SUCCESS
    }
    else {
        Write-Error 'PowerPlanHighPerformanceNotSet'
    }

    # remove balanced power plan
    Write-STStatus -Message 'Deleting Power Plan: Balanced' -Level INFO
    powercfg.exe /D $BalancedGuid
    if (!$LASTEXITCODE) {
        Write-STStatus -Message 'Deleted Power Plan: Balanced' -Level SUCCESS
    }
    else {
        Write-Error 'PowerPlanBalancedNotDeleted'
    }

    # remove power saver power plan
    Write-STStatus -Message 'Deleting Power Plan: Power Saver' -Level INFO
    powercfg.exe /D $PowerSaverGuid
    if (!$LASTEXITCODE) {
        Write-STStatus -Message 'Deleted Power Plan: Power Saver' -Level SUCCESS
    }
    else {
        Write-Error 'PowerPlanPowerSaverNotDeleted'
    }
}

function Main {
    [CmdletBinding()]
    param()
    <#
    .SYNOPSIS
        Executes the full post-installation workflow.
    .DESCRIPTION
        Installs required agents and applications, copies administrative files,
        enables .NET Framework and sets the power plan before joining the
        computer to the domain.
    #>
    # install agents
    Write-STStatus -Message 'Executing Agent Installers' -Level INFO
    Install-[REDACTED] -USB
    Install-[REDACTED] 
    Install-Sysmon 
    Install-[REDACTED]
    Read-Host -Prompt "Press enter to continue..." 

    # Install winget applications
    Write-STStatus -Message 'Update App Installer...' -Level INFO
    MSStoreAppInstallerUpdate
    Read-Host -Prompt "Press enter to continue..."

    # ensure winget is available before installing packages
    Assert-WingetInstalled

    # install applications
    Write-STStatus -Message 'Installing Chrome, Excel Mobile, and Adobe Acrobat Reader...' -Level INFO
    Install-Chrome
    Install-ExcelMobile
    Install-AdobeAcrobatReader

    # configure
    Write-STStatus -Message 'Enabling .NET Frame 3.5...' -Level INFO
    Enable-NetFramework

    # copy files
    Copy-Files -USB

    Write-STStatus -Message 'Setting Power Plan...' -Level INFO
    Set-PowerPlan

    # name computer
    Write-STStatus -Message 'Renaming Computer...' -Level INFO
    $NewComputerName = Get-ComputerName
    Rename-Computer -NewName $NewComputerName -Force

    # add computer to domain
    Write-STStatus -Message 'Adding Computer to domain...Press [CTRL] + [C] to abort...' -Level WARN
    Add-Computer -NewName $NewComputerName -DomainName "myus.local" -DomainCredential (Get-Credential) -Force

    Write-STStatus -Message 'Restart computer to apply changes...' -Level INFO

}

