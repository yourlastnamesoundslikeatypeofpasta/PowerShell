function Get-FailedLogins {
    <#
    .SYNOPSIS
        Get failed login attempts from a system.    
    .DESCRIPTION
        Using Get-WinEvent get failed login attempts from a system. 
        ErrorID: 4625 is used.
        Returned: an array of objects with TimeCreated and Message properties.
    
    .PARAMETER ComputerName
        System name.
    
    .EXAMPLE
        Get-FailedLogins -ComputerName "DC01"
    
    .NOTES
        None
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$ComputerName
    )

    if ($ComputerName -eq $null) {
        $ComputerName = $env:COMPUTERNAME
    }

    $failedLogins = Get-WinEvent -FilterHashTable @{LogName="Security"; ID=4625} -ComputerName $ComputerName | 
        Select-Object TimeCreated, Message

    return $failedLogins
}

Get-FailedLogins -ComputerName "DC01"

