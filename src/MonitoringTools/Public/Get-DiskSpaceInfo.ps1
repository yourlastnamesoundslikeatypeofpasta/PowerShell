function Get-DiskSpaceInfo {
    <#
    .SYNOPSIS
        Retrieves disk usage information.
    .DESCRIPTION
        Returns drive size and free space for fixed disks.
        Logs a structured entry via Write-STRichLog.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$TranscriptPath
    )

    if ($TranscriptPath) { Start-Transcript -Path $TranscriptPath -Append | Out-Null }
    $computer = if ($env:COMPUTERNAME) { $env:COMPUTERNAME } else { $env:HOSTNAME }
    $time = Get-Date -Format 'o'
    try {
        if ($IsWindows) {
            $disks = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType = 3"
            $info = foreach ($d in $disks) {
                [pscustomobject]@{
                    Drive       = $d.DeviceID
                    SizeGB      = [math]::Round($d.Size / 1GB,2)
                    FreeGB      = [math]::Round($d.FreeSpace / 1GB,2)
                    FreePercent = if ($d.Size -gt 0) { [math]::Round(($d.FreeSpace/$d.Size)*100,2) } else { 0 }
                }
            }
        } else {
            $info = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Free -ne $null } | ForEach-Object {
                [pscustomobject]@{
                    Drive       = $_.Root
                    SizeGB      = [math]::Round($_.Used/1GB + $_.Free/1GB,2)
                    FreeGB      = [math]::Round($_.Free/1GB,2)
                    FreePercent = if ($_.Used + $_.Free -gt 0) { [math]::Round(($_.Free/($_.Used+$_.Free))*100,2) } else { 0 }
                }
            }
        }
        Write-STRichLog -Tool 'Get-DiskSpaceInfo' -Status 'success' -Details @("ComputerName=$computer","Timestamp=$time","DriveCount=$($info.Count)")
        $info
    } catch {
        Write-STRichLog -Tool 'Get-DiskSpaceInfo' -Status 'error' -Details @("ComputerName=$computer","Timestamp=$time","Error=$($_.Exception.Message)")
        return New-STErrorRecord -Message $_.Exception.Message -Exception $_.Exception
    } finally {
        if ($TranscriptPath) { Stop-Transcript | Out-Null }
    }
}
