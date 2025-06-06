function Clear-TempFile {
    <#
    .SYNOPSIS
        Removes temporary files from the repository.
    .DESCRIPTION
        Wraps the CleanupTempFiles.ps1 script in the scripts folder and forwards any provided arguments.
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true, ValueFromPipeline=$true)]
        [object[]]$Arguments,
        [string]$TranscriptPath
    )
    process {
        Invoke-ScriptFile -Name "CleanupTempFiles.ps1" -Args $Arguments -TranscriptPath $TranscriptPath
    }
}
