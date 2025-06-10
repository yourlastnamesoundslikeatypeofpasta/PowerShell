Import-Module (Join-Path $PSScriptRoot '..' 'src/Logging/Logging.psd1') -Force -ErrorAction SilentlyContinue

function Set-ComputerIPAddress {
    [CmdletBinding()]
    <#
    .SYNOPSIS
        Set a systems static IP address.
    
    .DESCRIPTION
        Set a systems static IP address using a CSV file.
        The CSV file will have two columns. 
        Col1: ComputerName
        Col2: StaticIPAddress
    
    .PARAMETER CSVPath
        Path to CSV file.
    
    .EXAMPLE
        Set-ComputerIPAddress -CSVPath D:\ComputerIPAddress.csv
    
    .NOTES
        This function is meant to be ran on locally on a system. 
        https://www.pdq.com/blog/how-to-use-powershell-to-set-static-and-dhcp-ip-addresses/
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $CSVPath
    )

    if (-not (Test-Path $CSVPath))
    {
        Write-STStatus -Message 'CSV file not found.' -Level ERROR
        return
    }

    $CSV = Import-Csv -Path $CSVPath

    if ($CSV)
    {
        # set ip address here
        $MaskBits = 24 # set subnet mask to 255.255.255.0
        $Gateway = "192.168.1.1"
        $DNS = "8.8.8.8"
        $IPType = "IPv4"
        
        # grab the adapter to change
        # changing ethernet
        $adapter = Get-NetAdapter -Name "Ethernet"
        $matched = $false
        foreach ($Computer in $CSV)
        {
            if ($Computer.ComputerName -eq $ENV:COMPUTERNAME)
            {
                # remove the current ip address, gateway from
                # the adapter
                if (($adapter | Get-NetIPConfiguration).IPv4Address.IPv4Address)
                {
                    $adapter | Remove-NetIPAddress -AddressFamily $IPType -Confirm:$false
                }
                if (($adapter | Get-NetIPConfiguration).IPv4DefaultGateway.Address)
                {
                    $adapter | Remove-NetRoute -AddressFamily $IPType -Confirm:$false
                }

                # configure the new ip address and default gateway
                $adapter | New-NetIPAddress
                    -AddressFamily $IPType
                    -IPAddress $Computer.StaticIPAddress
                    -PrefixLength $MaskBits
                    -DefaultGateway $Gateway
            }
            
            # set dns server
            $adapter | Set-DnsClientServerAddress -ServerAddresses $DNS

            # restart net adapter and flush dns
            Restart-NetAdapter -Name "Ethernet"
            Clear-DnsClientCache

            $matched = $true
            break
        }
        if (-not $matched)
        {
            Write-STStatus -Message 'No matching computer name found in CSV file.' -Level WARN
        }
        
    }
    else
    {
        Write-STStatus -Message 'CSV file not found.' -Level ERROR
    }

}