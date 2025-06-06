function Clear-ArchiveFolder {
    <#
    .SYNOPSIS
        Removes files and folders from the archived SharePoint directory.
    .DESCRIPTION
        This function wraps the CleanupArchive.ps1 script in the scripts folder.
        All parameters are forwarded to that script.
    #>
    [CmdletBinding()]
    param(
        [string]$TranscriptPath,
        [switch]$EnableTranscript,
        [Parameter(ValueFromRemainingArguments=$true, ValueFromPipeline=$true)]
        [object[]]$Arguments
    )
    process {
        Invoke-ScriptFile -Name "CleanupArchive.ps1" -TranscriptPath $TranscriptPath -EnableTranscript:$EnableTranscript -Args $Arguments
    }
}
