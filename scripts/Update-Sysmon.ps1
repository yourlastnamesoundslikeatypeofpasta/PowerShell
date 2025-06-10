#
# <#
# .SYNOPSIS
# Update Sysmon to a specific version.
#
# .DESCRIPTION
# Locates the Sysmon files on a removable drive, copies them to the local
# system, reinstalls the service and verifies that it is running. The
# computer name is written to a log directory on the removable drive.
# #>

Import-Module (Join-Path $PSScriptRoot '..' 'src/Logging/Logging.psd1') -Force -ErrorAction SilentlyContinue

function Main {
    [CmdletBinding()]
    param()

    # get the correct drive letter
    $driveLetters = @("D", "E", "F", "G")
    foreach ($driverLetter in $driveLetters)
    {
        $drivePath = "$($driverLetter):\SYSV2\"
        Write-STStatus $drivePath -Level INFO
        $isDrivePathValid = Test-Path $drivePath
        if ($isDrivePathValid)
        {
            break
        }
    }

    # copy the updated sysmon dir to c drive
    $repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
    $defaultsFile = Join-Path $repoRoot 'config/config.psd1'
    $STDefaults = Get-STConfig -Path $defaultsFile
    $sysmonDir = Get-STConfigValue -Config $STDefaults -Key 'SysmonDir'

    Copy-Item -Path $drivePath -Destination $sysmonDir  -Recurse -Verbose

    Start-Sleep -Seconds 2

    # change working dir to c drive
    Set-Location -Path $sysmonDir -Verbose

    # uninstall sysmon
    .\Sysmon64.exe -u force

    Start-Sleep -Seconds 2

    # install sysmon
    .\Sysmon64.exe -i -accepteula

    Start-Sleep -Seconds 2

    # confirm sysmon is running
    $isSysmonRunning = (Get-Service SysMain | select Status).Status
    if ($isSysmonRunning -eq "Running")
    {
        Write-STStatus -Message 'Sysmon64 is running...' -Level INFO
    }
    else 
    {
        Write-STStatus -Message 'Sysmon64 is NOT running...' -Level WARN
    }

    # export computer name to log dir
    New-Item "$($driverLetter):\LOG\$($env:COMPUTERNAME).txt"
}
Main @args

