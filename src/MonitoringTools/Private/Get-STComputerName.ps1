function Get-STComputerName {
    <#
    .SYNOPSIS
        Returns the current system's computer name.
    .DESCRIPTION
        Cross-platform helper that checks common environment variables and
        falls back to [System.Net.Dns]::GetHostName() if needed.
    #>
    [CmdletBinding()]
    param()

    if ($env:COMPUTERNAME) { return $env:COMPUTERNAME }
    if ($env:HOSTNAME)     { return $env:HOSTNAME }
    try {
        return [System.Net.Dns]::GetHostName()
    } catch {
        return 'localhost'
    }
}
