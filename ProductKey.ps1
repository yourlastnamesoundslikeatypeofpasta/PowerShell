# the purpose of this script is to quickly grab the windows 10 
# product key off of decommissioned Win10 devices

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