function Get-DiskSpaceInfo {
    <#
    .SYNOPSIS
        Retrieves disk usage information.
    .DESCRIPTION
        Returns drive size and free space for fixed disks.
        A structured log entry describing disk usage is written on each call.
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$TranscriptPath
    )

    if (-not $PSCmdlet.ShouldProcess('disk space information')) { return }

    $computer = Get-STComputerName
    $timestamp = (Get-Date).ToString('o')
    if ($TranscriptPath) { Start-Transcript -Path $TranscriptPath -Append | Out-Null }
    try {
        if ($IsWindows) {
            $info = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType = 3" |
                ForEach-Object {
                    [pscustomobject]@{
                        Drive       = $_.DeviceID
                        SizeGB      = [math]::Round($_.Size / 1GB,2)
                        FreeGB      = [math]::Round($_.FreeSpace / 1GB,2)
                        FreePercent = if ($_.Size -gt 0) { [math]::Round(($_.FreeSpace/$_.Size)*100,2) } else { 0 }
                    }
                }
        } else {
            $info = Get-PSDrive -PSProvider FileSystem | Where-Object { $null -ne $_.Free } |
                ForEach-Object {
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
    $json = @{ ComputerName = $computer; Timestamp = $timestamp; DiskInfo = $info } | ConvertTo-Json -Compress
    Write-STRichLog -Tool 'Get-DiskSpaceInfo' -Status 'queried' -Details $json
    return $info
}
