function Get-DiskSpace {
    <#
    .SYNOPSIS
        Returns disk usage information.
    .DESCRIPTION
        Uses CIM or WMI classes to collect disk size and free space details.
    .PARAMETER ComputerName
        Optional remote computer name. Defaults to local computer.
    #>
    [CmdletBinding()]
    param(
        [string]$ComputerName = $env:COMPUTERNAME
    )
    process {
        try {
            if (Get-Command -Name Get-CimInstance -ErrorAction SilentlyContinue) {
                $diskInfo = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType = 3" -ComputerName $ComputerName
            } else {
                $diskInfo = Get-WmiObject -Class Win32_LogicalDisk -Filter "DriveType = 3" -ComputerName $ComputerName
            }
            $diskInfo | Select-Object DeviceID,
                @{Name='SizeGB';Expression={ [math]::Round($_.Size/1GB,2) }},
                @{Name='FreeGB';Expression={ [math]::Round($_.FreeSpace/1GB,2) }}
        } catch {
            Write-STStatus "Get-DiskSpace failed: $_" -Level ERROR -Log
            return New-STErrorObject -Message $_.Exception.Message -Category 'WMI'
        }
    }
}
