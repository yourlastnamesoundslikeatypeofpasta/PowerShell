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
        [Parameter(ValueFromRemainingArguments=$true, ValueFromPipeline=$true)]
        [object[]]$Arguments,
        [string]$TranscriptPath,
        [switch]$Simulate
    )
    process {
        Invoke-ScriptFile -Name "CleanupArchive.ps1" -Args $Arguments -TranscriptPath $TranscriptPath -Simulate:$Simulate
    }
}
