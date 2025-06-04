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

function Main {

    # get the correct drive letter
    $driveLetters = @("D", "E", "F", "G")
    foreach ($driverLetter in $driveLetters)
    {
        $drivePath = "$($driverLetter):\SYSV2\"
        Write-Host $drivePath
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
        Write-Information -MessageData "Sysmon64 is running..." -InformationAction Continue
    }
    else 
    {
        Write-Warning -Message "Sysmon64 is NOT running..." -WarningAction Continue
    }

    # export computer name to log dir
    New-Item "$($driverLetter):\LOG\$($env:COMPUTERNAME).txt"
}

Main
