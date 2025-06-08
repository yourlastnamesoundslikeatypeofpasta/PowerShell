param(
    [Parameter(Mandatory)]
    [string]$XlsxFilePath
)
Import-Module (Join-Path $PSScriptRoot '..' 'src/SupportTools/SupportTools.psd1') -Force
Convert-ExcelToCsv -XlsxFilePath $XlsxFilePath
