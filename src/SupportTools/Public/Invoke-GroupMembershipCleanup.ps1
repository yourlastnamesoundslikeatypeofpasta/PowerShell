function Invoke-GroupMembershipCleanup {
    <#
    .SYNOPSIS
        Cleans up group membership by removing disabled users.
    .DESCRIPTION
        This wrapper executes Cleanup-GroupMembership.ps1 from the scripts folder
        and forwards any provided arguments.
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true, ValueFromPipeline=$true)]
        [object[]]$Arguments,
        [string]$TranscriptPath
    )
    process {
        Invoke-ScriptFile -Name 'Cleanup-GroupMembership.ps1' -Args $Arguments -TranscriptPath $TranscriptPath
    }
}
