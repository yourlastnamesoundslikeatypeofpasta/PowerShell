function Start-RoleAwareToolset {
    <#
    .SYNOPSIS
        Launches the RoleAwareToolset menu.
    .PARAMETER UserRole
        Optional user role to pass to the script. Defaults to Helpdesk.
    #>
    [CmdletBinding()]
    param(
        [ValidateSet('Helpdesk','Site Admin')]
        [string]$UserRole = 'Helpdesk',
        [string]$TranscriptPath
    )
    $args = @('-UserRole', $UserRole)
    Invoke-ScriptFile -Name 'RoleAwareToolset.ps1' -Args $args -TranscriptPath $TranscriptPath
}
