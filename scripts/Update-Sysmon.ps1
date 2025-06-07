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

Import-Module (Join-Path $PSScriptRoot '..' 'src/Logging/Logging.psd1') -ErrorAction SilentlyContinue

function Main {

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
    Copy-Item -Path $drivePath -Destination "C:\SYSV2"  -Recurse -Verbose

    Start-Sleep -Seconds 2

    # change working dir to c drive
    Set-Location -Path "C:\SYSV2\" -Verbose

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
        Write-STStatus 'Sysmon64 is running...' -Level INFO
    }
    else 
    {
        Write-STStatus 'Sysmon64 is NOT running...' -Level WARN
    }

    # export computer name to log dir
    New-Item "$($driverLetter):\LOG\$($env:COMPUTERNAME).txt"
}

