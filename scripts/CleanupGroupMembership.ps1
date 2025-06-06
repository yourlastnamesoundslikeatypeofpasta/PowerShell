<#+
.SYNOPSIS
    Removes users from a Microsoft 365 group.
.DESCRIPTION
    Imports user principal names from a CSV file and removes each
    user from the target group if they are currently a member.
.EXAMPLE
    ./CleanupGroupMembership.ps1 -CsvPath users.csv -GroupName "Team"
#>

Import-Module (Join-Path $PSScriptRoot '..' 'src/Logging/Logging.psd1') -ErrorAction SilentlyContinue

param(
    [Parameter(Mandatory)][string]$CsvPath,
    [Parameter(Mandatory)][string]$GroupName
)

Write-STStatus 'Connecting to Microsoft Graph...' -Level INFO
Connect-MgGraph -Scopes "User.Read.All","Group.ReadWrite.All" -NoWelcome

$group = Get-MgGroup -Filter "displayName eq '$GroupName'" | Select-Object -First 1
if (-not $group) { throw "Group '$GroupName' not found." }

$users = Import-Csv $CsvPath
foreach ($user in $users.UPN) {
    $obj = Get-MgUser -UserId $user -ErrorAction SilentlyContinue
    if (-not $obj) { Write-Warning "User not found: $user"; continue }
    try {
        Remove-MgGroupMemberByRef -GroupId $group.Id -DirectoryObjectId $obj.Id -ErrorAction Stop
        Write-STStatus "Removed $($obj.UserPrincipalName)" -Level SUCCESS
    } catch {
        Write-Warning "Failed to remove $user: $_"
    }
}

Disconnect-MgGraph | Out-Null
Write-STStatus 'Group membership cleanup finished.' -Level SUCCESS
