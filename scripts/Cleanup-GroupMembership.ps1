<#+
.SYNOPSIS
    Removes disabled accounts from a Microsoft 365 group.
.DESCRIPTION
    Connects to Microsoft Graph, enumerates group members, and removes any member
    whose account is disabled.
.PARAMETER GroupName
    Display name of the group to clean up.
.PARAMETER TranscriptPath
    Optional transcript log path.
#>
param(
    [Parameter(Mandatory)]
    [string]$GroupName,
    [string]$TranscriptPath
)

Import-Module (Join-Path $PSScriptRoot '..' 'src' 'Logging' 'Logging.psd1') -ErrorAction SilentlyContinue

if ($TranscriptPath) { Start-Transcript -Path $TranscriptPath -Append | Out-Null }

if (-not (Get-Module Microsoft.Graph.Users -ListAvailable)) {
    Write-STStatus 'Installing Microsoft Graph...' -Level INFO -Log
    Install-Module Microsoft.Graph -Scope CurrentUser -Force
}

Import-Module Microsoft.Graph.Users,Microsoft.Graph.Groups -ErrorAction Stop
Connect-MgGraph -Scopes 'User.Read.All','Group.ReadWrite.All'

Write-STStatus "Processing group '$GroupName'" -Level INFO -Log
$group = Get-MgGroup -Filter "displayName eq '$GroupName'" | Select-Object -First 1
if (-not $group) { throw "Group '$GroupName' not found." }
$members = Get-MgGroupMember -GroupId $group.Id -All
foreach ($member in $members) {
    $user = Get-MgUser -UserId $member.Id -ErrorAction SilentlyContinue
    if ($user -and $user.AccountEnabled -eq $false) {
        Remove-MgGroupMemberByRef -GroupId $group.Id -DirectoryObjectId $member.Id -Confirm:$false
        Write-STStatus "Removed disabled account: $($user.UserPrincipalName)" -Level WARN -Log
    }
}
Write-STStatus 'Group membership cleanup complete.' -Level FINAL -Log
if ($TranscriptPath) { Stop-Transcript | Out-Null }
