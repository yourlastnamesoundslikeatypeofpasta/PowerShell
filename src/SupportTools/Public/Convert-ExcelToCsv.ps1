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
        [string]$TranscriptPath,
        [switch]$EnableTranscript,
        [Parameter(ValueFromRemainingArguments=$true, ValueFromPipeline=$true)]
        [object[]]$Arguments
    )
    process {
        Invoke-ScriptFile -Name "Convert-ExcelToCsv.ps1" -TranscriptPath $TranscriptPath -EnableTranscript:$EnableTranscript -Args $Arguments
    }
}
