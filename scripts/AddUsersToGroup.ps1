<#
.SYNOPSIS
This script connects to Microsoft Graph, imports a CSV file containing user principal names (UPNs), and adds the users to a specified Microsoft 365 group if they are not already members.

.DESCRIPTION
The script performs the following actions:
1. Installs and imports the Microsoft Graph PowerShell module if not already installed.
2. Connects to Microsoft Graph using specified permissions.
3. Prompts the user to select a CSV file containing UPNs using a file dialog.
4. Retrieves a list of all Microsoft 365 groups and prompts the user to select a group.
5. Checks if each user in the CSV file is already a member of the selected group.
6. Adds any users who are not already members to the selected group.
7. Outputs success and error messages to indicate the status of each operation.

The script includes several helper functions to manage tasks such as connecting to Microsoft Graph, retrieving groups and users, and handling the CSV file selection.

.PARAMETER siteUrl
The URL of the SharePoint site containing the document library.

.PARAMETER libraries
The name of the document library to be processed.

.NOTES
This script requires Microsoft Graph API permissions and assumes the user has the necessary permissions to connect to Microsoft Graph and manage groups and users. It is intended for use in scenarios where bulk user management is required for Microsoft 365 groups.


.EXAMPLE
    .\AddUsersToGroup.ps1 -CsvPath users.csv -GroupName "Target Group"
This example runs the script with explicit parameters to process the provided CSV file and add the listed users to the specified Microsoft 365 group.
#>

[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [Parameter()]
    [string]$CsvPath,

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$GroupName,

    [Parameter()]
    [ValidateSet('Entra','AD')]
    [string]$Cloud = 'Entra'
)

. $PSScriptRoot/Common.ps1
Import-SupportToolsLogging

# Import necessary .NET assemblies
Add-Type -AssemblyName PresentationFramework, System.Windows.Forms
$InformationPreference = "Continue"

if ($Cloud -eq 'Entra') {
    # Install Microsoft Graph module if not already installed
    $isMicrosoftGraphInstalled = Get-Module -Name Microsoft.Graph.*
    if (!$isMicrosoftGraphInstalled) {
        Write-STStatus -Message 'Microsoft Graph not installed...installing Microsoft Graph PowerShell Module...' -Level WARN
        Install-Module Microsoft.Graph
    }

    # Import Microsoft Graph module
    Write-STStatus -Message 'Importing Microsoft Graph...this might take awhile...' -Level INFO
    Import-Module Microsoft.Graph -Verbose
} else {
    Import-Module ActiveDirectory -ErrorAction Stop
}

function Get-CSVFilePath {
    Write-STStatus -Message 'Select CSV from file dialog...' -Level SUB
    # Open file dialog to get CSV path
    $openFileDialog = New-Object Microsoft.Win32.OpenFileDialog
    $openFileDialog.InitialDirectory = [Environment]::GetFolderPath('MyDocuments')
    $openFileDialog.Filter = "CSV files (*.csv)|*.csv|All files (*.*)|*.*"
    $dialogResult = $openFileDialog.ShowDialog()

    if ($dialogResult -eq "True")
    {
        $filePath = Get-ChildItem -Path $openFileDialog.FileName
        return $filePath
    }
    else {
        Write-STStatus -Message 'No file selected' -Level SUB
        return $null
    }
}

function Get-GroupNames {
    $allGroups = Get-MgGroup -All | select DisplayName, Id
    return $allGroups
}

function Connect-MicrosoftGraph {
    # Connect to Microsoft Graph API
    Write-STStatus -Message 'Connecting to Microsoft Graph...' -Level INFO
    $scopes = 'User.Read.All','Group.ReadWrite.All','Directory.ReadWrite.All'
    try {
        Connect-MgGraph -Scopes $scopes -NoWelcome
    } catch {
        Write-Error -Message "Error: $_.Exception.Message"
        throw "Error: Cannot connect to Microsoft Graph"
    }

    $mgGraphAccount = (Get-MgContext).Account
    $messageData = "Microsoft Graph Account: $mgGraphAccount"
    Write-STStatus $messageData -Level INFO
    Write-STStatus ('-' * $messageData.Length) -Level INFO
}

function Get-Group {
    param(
        [string]$GroupName
    )

    if ($GroupName) {
        $grp = Get-MgGroup -Filter "displayName eq '$GroupName'" | Select-Object -First 1
        if (-not $grp) { throw "Group '$GroupName' not found." }
            Write-STStatus "Using group: $($grp.DisplayName)" -Level SUB
        return $grp
    }

    $allGroupNames = Get-GroupNames | Sort-Object -Property DisplayName
    $index = 0
    foreach ($group in $allGroupNames) {
        Write-STStatus "[$($index)] - $($group.DisplayName)" -Level INFO
        $index++
    }

    $groupSelection = Read-Host -Prompt "Select a group"

    try {
        $selectedGroup = $allGroupNames[$groupSelection]
        Write-STStatus "You have selected: $($selectedGroup.DisplayName)" -Level SUB
    } catch {
        Write-Error "Error: $($_.Exception.Message)"
        throw "Error: There was an error with your selection..."
    }

    $selectedGroup
}

function Get-GroupExistingMembers {
    param(
        [object]
        $Group
    )
    $existingMembers = Get-MgGroupMember -GroupId $group.Id

    $existingMemberUPNList = [System.Collections.Generic.List[object]]::new()
    foreach ($id in $existingMembers.Id)
    {
        $UPN = Get-MgUser -UserId $id | select UserPrincipalName
        $existingMemberUPNList.Add($UPN.UserPrincipalName)
    }

    $existingMemberUPNList
}

function Get-UserID {
    param(
        [string]
        $UserPrincipalName
    )

    try {
        return Get-MgUser -UserId $UserPrincipalName -ErrorAction Stop
    }
    catch {
        Write-STStatus "User not found: $UserPrincipalName" -Level WARN
        return $null
    }
}

function Start-Main {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [string]$CsvPath,
        [string]$GroupName,
        [string]$Cloud = 'Entra'
    )

    if ($Cloud -eq 'Entra') {
        # Connect to Microsoft Graph
        try {
            Connect-MicrosoftGraph -ErrorAction Stop
        }
        catch {
            Write-Error "[ERROR] Connecting to Microsoft Graph $($_.Exception.Message)"
            throw "[ERROR] Connecting to Microsoft Graph..."
        }

        # Get all groups and query the user for a group index
        $group = Get-Group -GroupName $GroupName
        $groupExistingMembers = Get-GroupExistingMembers -Group $group
    } else {
        $group = Get-ADGroup -Identity $GroupName -ErrorAction Stop
        $groupExistingMembers = (Get-ADGroupMember -Identity $group.DistinguishedName -Recursive | Select-Object -ExpandProperty SamAccountName)
    }

    # Import the CSV file with UPN header
    if (-not $CsvPath) { $CsvPath = Get-CSVFilePath }
    $filePath = $CsvPath
    $file = Import-STCsv -Path $filePath
    $users = $file.UPN

    $addedUsers = [System.Collections.Generic.List[object]]::new()
    $skippedUsers = [System.Collections.Generic.List[object]]::new()

    # Check if user is in the group and add the user if not
    foreach ($user in $users)
    {
        if ($Cloud -eq 'Entra') {
            # Pull all info | select UPN
            $userInfo = Get-UserID -UserPrincipalName $user
            $uid = $userInfo.Id
            $upn = $userInfo.UserPrincipalName
            $display = $userInfo.DisplayName
        } else {
            $userInfo = Get-ADUser -Filter "UserPrincipalName -eq '$user'" -ErrorAction SilentlyContinue
            if (-not $userInfo) { $userInfo = Get-ADUser -Identity $user -ErrorAction SilentlyContinue }
            $uid = $userInfo.SamAccountName
            $upn = $userInfo.UserPrincipalName
            $display = $userInfo.Name
        }

        if (-not $userInfo) {
            $skippedUsers.Add($user)
            Write-STStatus "User not found: $user" -Level WARN
            continue
        }

        # Add the user to the group if they are not in the group
        if ($groupExistingMembers -contains $upn)
        {
            Write-STStatus "UserIsInGroup: $($user) - $($group.DisplayName)" -Level WARN
            $skippedUsers.Add($upn)
        }
        else {
            if ($PSCmdlet.ShouldProcess($display, "Add to group $($group.DisplayName)")) {
                Write-STStatus "AddingUserToGroup: User: $display - Group: $($group.DisplayName)" -Level INFO
                try {
                    if ($Cloud -eq 'Entra') {
                        New-MgGroupMember -GroupId $group.Id -DirectoryObjectId $uid -ErrorAction Stop
                    } else {
                        Add-ADGroupMember -Identity $group.DistinguishedName -Members $uid -ErrorAction Stop
                    }
                    Write-STStatus "[SUCCESS] AddingUserToGroup: User: $display - Group: $($group.DisplayName)" -Level SUCCESS
                    $addedUsers.Add($upn)
                }
                catch {
                    Write-Error "[FAIL] Error adding $($user) to $($group.Id)..."
                    throw "ErrorAddingUserToGroup: $($user): $display"
                }
            } else {
                Write-STStatus "WouldAddUserToGroup: User: $display - Group: $($group.DisplayName)" -Level SUB
            }
        }
    }

    Write-STStatus -Message 'Task Completed.' -Level FINAL
    if ($Cloud -eq 'Entra') {
        Write-STStatus -Message 'Disconnecting from Microsoft Graph...' -Level INFO
        Disconnect-MgGraph | Out-Null
        Write-STStatus -Message 'Disconnected from Microsoft Graph' -Level SUCCESS
    }

    [pscustomobject]@{
        GroupName    = $group.DisplayName
        AddedUsers   = $addedUsers
        SkippedUsers = $skippedUsers
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    Start-Main -CsvPath $CsvPath -GroupName $GroupName -Cloud $Cloud
}
