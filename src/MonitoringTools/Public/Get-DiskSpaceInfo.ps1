function Get-DiskSpaceInfo {
    <#
    .SYNOPSIS
        Retrieves disk usage information.
    .DESCRIPTION
        Returns drive size and free space for fixed disks.
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$TranscriptPath
    )

    if ($TranscriptPath) { Start-Transcript -Path $TranscriptPath -Append | Out-Null }
    try {
        if ($IsWindows) {
            $disks = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType = 3"
            foreach ($d in $disks) {
                [pscustomobject]@{
                    Drive       = $d.DeviceID
                    SizeGB      = [math]::Round($d.Size / 1GB,2)
                    FreeGB      = [math]::Round($d.FreeSpace / 1GB,2)
                    FreePercent = if ($d.Size -gt 0) { [math]::Round(($d.FreeSpace/$d.Size)*100,2) } else { 0 }
                }
            }
        } else {
            Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Free -ne $null } | ForEach-Object {
                [pscustomobject]@{
                    Drive       = $_.Root
                    SizeGB      = [math]::Round($_.Used/1GB + $_.Free/1GB,2)
                    FreeGB      = [math]::Round($_.Free/1GB,2)
                    FreePercent = if ($_.Used + $_.Free -gt 0) { [math]::Round(($_.Free/($_.Used+$_.Free))*100,2) } else { 0 }
                }
            }
        }
    } catch {
        return New-STErrorRecord -Message $_.Exception.Message -Exception $_.Exception
    } finally {
        if ($TranscriptPath) { Stop-Transcript | Out-Null }
    }
}
