<#+
.SYNOPSIS
    Consolidate forensic data for immediate incident response.
.DESCRIPTION
    Collects recent Security and System event logs, running process
    details with file hashes and signatures, logged in users, network
    connections, local administrators, services and startup items.
    Results are saved to a timestamped folder. If unsigned processes
    executing from temporary directories are detected, the script
    triggers New-SimpleTicket from the ServiceDeskTools module.
.PARAMETER OutputDirectory
    Directory to store collected data. Defaults to a folder in TEMP.
.PARAMETER RequesterEmail
    Email address used when submitting a Service Desk ticket.
.PARAMETER TranscriptPath
    Optional transcript log path.
#>
[CmdletBinding()]
param(
    [string]$OutputDirectory = (Join-Path $env:TEMP "IR_$((Get-Date).ToString('yyyyMMdd_HHmmss'))"),
    [string]$RequesterEmail,
    [string]$TranscriptPath
)

if (-not (Get-Module -Name 'Logging')) {
    Import-Module (Join-Path $PSScriptRoot '..' 'src/Logging/Logging.psd1') -Force -ErrorAction SilentlyContinue
}
Import-Module (Join-Path $PSScriptRoot '..' 'src/ServiceDeskTools/ServiceDeskTools.psd1') -Force -ErrorAction SilentlyContinue

if ($TranscriptPath) { Start-Transcript -Path $TranscriptPath -Append | Out-Null }

try {
    New-Item -Path $OutputDirectory -ItemType Directory -Force | Out-Null
    Write-STStatus "Collecting event logs" -Level INFO -Log
    Get-WinEvent -LogName Security -MaxEvents 200 | Export-Clixml -Path (Join-Path $OutputDirectory 'Security.xml')
    Get-WinEvent -LogName System   -MaxEvents 200 | Export-Clixml -Path (Join-Path $OutputDirectory 'System.xml')

    Write-STStatus "Gathering process information" -Level INFO -Log
    $processes = Get-Process | ForEach-Object {
        $path = $_.Path
        $hash = $null
        $signer = $null
        if ($path) {
            try { $hash = (Get-FileHash -Algorithm SHA256 -Path $path).Hash } catch {}
            try {
                $sig = Get-AuthenticodeSignature -FilePath $path
                if ($sig.SignerCertificate) { $signer = $sig.SignerCertificate.Subject }
            } catch {}
        }
        [pscustomobject]@{
            Name   = $_.ProcessName
            Id     = $_.Id
            Path   = $path
            Hash   = $hash
            Signer = $signer
        }
    }
    $procPath = Join-Path $OutputDirectory 'Processes.csv'
    $processes | Export-Csv -NoTypeInformation -Path $procPath -Encoding utf8

    Write-STStatus "Capturing user sessions" -Level INFO -Log
    try { qwinsta | Out-File -FilePath (Join-Path $OutputDirectory 'LoggedInUsers.txt') -Encoding utf8 }
    catch { Write-STStatus "qwinsta failed: $_" -Level WARN -Log }

    Write-STStatus "Listing network connections" -Level INFO -Log
    Get-NetTCPConnection | Select-Object LocalAddress,LocalPort,RemoteAddress,RemotePort,State |
        Export-Csv -NoTypeInformation -Path (Join-Path $OutputDirectory 'NetConnections.csv') -Encoding utf8

    Write-STStatus "Enumerating local administrators" -Level INFO -Log
    try {
        Get-LocalGroupMember -Group 'Administrators' |
            Select-Object Name,SID |
            Export-Csv -NoTypeInformation -Path (Join-Path $OutputDirectory 'LocalAdmins.csv') -Encoding utf8
    } catch {
        Write-STStatus "Failed to list local admins: $_" -Level WARN -Log
    }

    Write-STStatus "Recording services and startup items" -Level INFO -Log
    Get-Service | Select-Object Name,DisplayName,Status,StartType |
        Export-Csv -NoTypeInformation -Path (Join-Path $OutputDirectory 'Services.csv') -Encoding utf8
    Get-CimInstance Win32_StartupCommand | Select-Object Name,Command,Location,User |
        Export-Csv -NoTypeInformation -Path (Join-Path $OutputDirectory 'StartupItems.csv') -Encoding utf8

    $highRisk = $processes | Where-Object { -not $_.Signer -and $_.Path -match '(?i)\\temp\\' }
    if ($highRisk.Count -gt 0 -and $RequesterEmail) {
        Write-STStatus "High-risk processes detected" -Level ERROR -Log
        $desc = "Unsigned processes found in temp locations on $env:COMPUTERNAME.`n`n" +
                 ($highRisk | Format-Table Name,Path -AutoSize | Out-String) +
                 "`nReport folder: $OutputDirectory"
        New-SimpleTicket -Subject "Incident Response - $env:COMPUTERNAME" -Description $desc -RequesterEmail $RequesterEmail | Out-Null
    }

    Write-STStatus "Incident response data saved to $OutputDirectory" -Level SUCCESS -Log
} finally {
    if ($TranscriptPath) { Stop-Transcript | Out-Null }
}
