
Import-Module (Join-Path $PSScriptRoot '..' 'src/Logging/Logging.psd1') -Force -ErrorAction SilentlyContinue

function Get-NetworkShares {
    <#
    .SYNOPSIS
        Get network shares from a computer
    .DESCRIPTION
        Get network shares from a computer
    .PARAMETER ComputerName
        The name of the computer to get network shares from
    .EXAMPLE
        Get-NetworkShares -ComputerName "$ENV:COMPUTERNAME"    
    .NOTES
    #>

    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$ComputerName
    )

    # if $ComputerName is null, use the local computer
    if ($ComputerName -eq $null) {
        $ComputerName = $env:COMPUTERNAME
    }
    Write-STStatus -Message "Gathering network shares on $ComputerName..." -Level INFO

    $shares = Get-CimInstance -ClassName Win32_Share -ComputerName $ComputerName

    $shareObjects = foreach ($share in $shares) {
        [pscustomobject]@{
            ShareName   = $share.Name
            Path        = $share.Path
            Description = $share.Description
            Type        = $share.Type
        }
    }

    $result = [pscustomobject]@{
        ComputerName = $ComputerName
        Shares       = $shareObjects
    }

    Write-STStatus -Message "Found $($shareObjects.Count) shares." -Level SUCCESS
    return $result
}





