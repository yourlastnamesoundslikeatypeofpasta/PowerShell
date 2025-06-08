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
param(
    [Parameter(Mandatory)]
    [string]$OutputPath
)
Import-Module (Join-Path $PSScriptRoot '..' 'src/SupportTools/SupportTools.psd1') -Force
Export-ProductKey -OutputPath $OutputPath

