function Restore-ArchiveFolder {
    <#
    .SYNOPSIS
        Restores files and folders removed by Clear-ArchiveFolder.
    .DESCRIPTION
        Wraps the RollbackArchive.ps1 script in the scripts folder.
        All parameters are forwarded to that script.
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true, ValueFromPipeline=$true)]
        [object[]]$Arguments,
        [string]$TranscriptPath
    )
    process {
        Invoke-ScriptFile -Name "RollbackArchive.ps1" -Args $Arguments -TranscriptPath $TranscriptPath
    }
}
