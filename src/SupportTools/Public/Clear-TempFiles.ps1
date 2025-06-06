function Clear-TempFiles {
    <#
    .SYNOPSIS
        Removes temporary files from the repository.
    .DESCRIPTION
        Wraps the CleanupTempFiles.ps1 script in the scripts folder and forwards any provided arguments.
    #>
    [CmdletBinding()]
    param(
        [string]$TranscriptPath,
        [switch]$EnableTranscript,
        [Parameter(ValueFromRemainingArguments=$true, ValueFromPipeline=$true)]
        [object[]]$Arguments
    )
    process {
        Invoke-ScriptFile -Name "CleanupTempFiles.ps1" -TranscriptPath $TranscriptPath -EnableTranscript:$EnableTranscript -Args $Arguments
    }
}
