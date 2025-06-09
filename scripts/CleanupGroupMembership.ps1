<#+
.SYNOPSIS
    Removes users from a Microsoft 365 group.
.DESCRIPTION
    Imports user principal names from a CSV file and removes each
    user from the target group if they are currently a member.
.EXAMPLE
    ./CleanupGroupMembership.ps1 -CsvPath users.csv -GroupName "Team"
#>

. $PSScriptRoot/Common.ps1
Import-SupportToolsLogging

param(
    [Parameter(Mandatory)][string]$CsvPath,
    [Parameter(Mandatory)][string]$GroupName,
    [ValidateSet('Entra', 'AD')][string]$Cloud = 'Entra'
)

if ($Cloud -eq 'Entra') {
    Write-STStatus -Message 'Connecting to Microsoft Graph...' -Level INFO
    Connect-MgGraph -Scopes "User.Read.All", "Group.ReadWrite.All" -NoWelcome

    $group = Get-MgGroup -Filter "displayName eq '$GroupName'" | Select-Object -First 1
    if (-not $group) { throw "Group '$GroupName' not found." }

    $users = Import-Csv $CsvPath
    foreach ($user in $users.UPN) {
        $obj = Get-MgUser -UserId $user -ErrorAction SilentlyContinue
        if (-not $obj) { Write-STStatus "User not found: $user" -Level WARN; continue }
        try {
            Remove-MgGroupMemberByRef -GroupId $group.Id -DirectoryObjectId $obj.Id -ErrorAction Stop
            Write-STStatus "Removed $($obj.UserPrincipalName)" -Level SUCCESS
        }
        catch {
            Write-STStatus "Failed to remove $user: $_" -Level ERROR
        }
    }

    Disconnect-MgGraph | Out-Null
}
else {
    Import-Module ActiveDirectory -ErrorAction Stop
    $group = Get-ADGroup -Identity $GroupName -ErrorAction Stop

    $users = Import-Csv $CsvPath
    foreach ($user in $users.UPN) {
        $obj = Get-ADUser -Filter "UserPrincipalName -eq '$user'" -ErrorAction SilentlyContinue
        if (-not $obj) { $obj = Get-ADUser -Identity $user -ErrorAction SilentlyContinue }
        if (-not $obj) { Write-STStatus "User not found: $user" -Level WARN; continue }
        try {
            Remove-ADGroupMember -Identity $group.DistinguishedName -Members $obj.SamAccountName -Confirm:$false -ErrorAction Stop
            Write-STStatus "Removed $($obj.UserPrincipalName)" -Level SUCCESS
        }
        catch {
            Write-STStatus "Failed to remove $user: $_" -Level ERROR
        }
    }
}

Write-STStatus -Message 'Group membership cleanup finished.' -Level SUCCESS
