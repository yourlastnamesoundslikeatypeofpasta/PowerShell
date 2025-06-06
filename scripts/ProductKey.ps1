<#

.SYNOPSIS
Retrieves the Windows product key and writes it to a file.

.DESCRIPTION
Queries the SoftwareLicensingService WMI class for the original product key of the current system.
The key is saved to the specified path.

.PARAMETER OutputPath
Path to the file where the product key should be written.

.EXAMPLE
ProductKey -OutputPath 'C:\\temp\\key.txt'

#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$OutputPath
)

function Get-ProductKey {
    $key = (Get-CimInstance -ClassName SoftwareLicensingService |
        Select-Object -ExpandProperty OA3xOriginalProductKey)
    return $key
}

$key = Get-ProductKey
if (-not $key) {
    Write-Warning 'Product key not found.'
    return
}

Set-Content -Path $OutputPath -Value $key
Write-Information -MessageData "Product key exported to $OutputPath" -InformationAction Continue

