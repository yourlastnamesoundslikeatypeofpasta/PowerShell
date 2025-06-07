function Convert-ExcelToCsv {
    <#
    .SYNOPSIS
        Converts an Excel workbook to CSV.
    .DESCRIPTION
        Wrapper for the Convert-ExcelToCsv.ps1 script contained in the scripts
        directory. Any arguments provided are passed to the script.
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true, ValueFromPipeline=$true)]
        [object[]]$Arguments,
        [string]$TranscriptPath,
        [switch]$Simulate,
        [switch]$Explain
    )
    process {
        Invoke-ScriptFile -Name "Convert-ExcelToCsv.ps1" -Args $Arguments -TranscriptPath $TranscriptPath -Simulate:$Simulate -Explain:$Explain
    }
}
