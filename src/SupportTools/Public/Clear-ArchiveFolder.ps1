function Clear-ArchiveFolder {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true, ValueFromPipeline=$true)]
        [object[]]$Arguments
    )
    process {
        Invoke-ScriptFile -Name "CleanupArchive.ps1" -Args $Arguments
    }
}
