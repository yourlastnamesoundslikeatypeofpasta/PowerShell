function Convert-ExcelToCsv {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true, ValueFromPipeline=$true)]
        [object[]]$Arguments
    )
    process {
        Invoke-ScriptFile -Name "Convert-ExcelToCsv.ps1" -Args $Arguments
    }
}
