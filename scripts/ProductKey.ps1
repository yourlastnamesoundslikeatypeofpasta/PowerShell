#
# <#
# .SYNOPSIS
# Retrieve and export the Windows product key.
#
# .DESCRIPTION
# Queries WMI for the original product key of the current system and
# saves it to a text file. Useful for archiving keys from
# decommissioned devices.
# #>

function Get-ProductKey 
{
    $originalProductKey = (Get-WmiObject -Class SoftwareLicensingService | select OA3xOriginalProductKey).OA3xOriginalProductKey
    return $originalProductKey
}

function Export-ProductKey
{
    param (
        [string] $ProductKey
    )
    $ProductKey | Add-Content "D:\keys.txt"
}

$key = Get-ProductKey
Export-ProductKey -ProductKey $key
