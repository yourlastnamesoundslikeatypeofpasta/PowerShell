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
.\AddUsersToGroup.ps1
This example runs the script, connecting to Microsoft Graph and processing the selected CSV file to add users to the chosen Microsoft 365 group.
#>

# Import necessary .NET assemblies
Add-Type -AssemblyName PresentationFramework, System.Windows.Forms
$InformationPreference = "Continue"

# Install Microsoft Graph module if not already installed
$isMicrosoftGraphInstalled = Get-Module -Name Microsoft.Graph.*
if (!$isMicrosoftGraphInstalled)
{
    Write-Host -ForegroundColor Yellow "Microsoft Graph not installed...installing Microsoft Graph PowerShell Module..."
    Install-Module Microsoft.Graph
}

# Import Microsoft Graph module
Write-Host -ForegroundColor Yellow "Importing Microsoft Graph...this might take awhile..."
Import-Module Microsoft.Graph -Verbose

function Get-CSVFilePath {
    Write-Host -ForegroundColor DarkMagenta "Select CSV from file dialog..."
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
        Write-Debug "No file selected"
        return $null
    }
}

function Get-GroupNames {
    $allGroups = Get-MgGroup -All | select DisplayName, Id
    return $allGroups
}

function Connect-MicrosoftGraph {
    # Connect to Microsoft Graph API
    Write-Host -ForegroundColor DarkCyan "Connecting to Microsoft Graph..."
    try {
        Connect-MgGraph -Scopes "User.Read.All", "Group.ReadWrite.All", "Directory.ReadWrite.All" -NoWelcome
    }
    catch {
        Write-Error -Message "Error: $_.Exception.Message"
        throw "Error: Cannot connect to Microsoft Graph"
    }

    $mgGraphAccount = (Get-MgContext).Account
    $messageData = "Microsoft Graph Account: $mgGraphAccount"
    Write-Information -MessageData $messageData
    Write-Information -MessageData ('-' * $messageData.Length)
}

function Get-Group {
    # Display all group names
    $allGroupNames = Get-GroupNames | Sort-Object -Property DisplayName
    $index = 0
    foreach ($group in $allGroupNames)
    {
        Write-Information -MessageData "[$($index)] - $($group.DisplayName)"
        $index++
    }

    $groupSelection = Read-Host -Prompt "Select a group"

    try {
        $selectedGroup = $allGroupNames[$groupSelection]
        Write-Host -ForegroundColor DarkYellow "You have selected: $($selectedGroup.DisplayName)"
    }
    catch {
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
    $id = Get-MgUser -All | where {$_.UserPrincipalName -eq $UserPrincipalName}

    $id
}

function Start-Main {
    # Connect to Microsoft Graph
    try {
        Connect-MicrosoftGraph -ErrorAction Stop
    }
    catch {
        Write-Error "[ERROR] Connecting to Microsoft Graph $($_.Exception.Message)"
        throw "[ERROR] Connecting to Microsoft Graph..."
    }

    # Get all groups and query the user for a group index
    $group = Get-Group
    $groupExistingMembers = Get-GroupExistingMembers -Group $group

    # Import the CSV file with UPN header
    $filePath = Get-CSVFilePath
    $file = Import-Csv $filePath
    $users = $file.UPN

    # Check if user is in the group and add the user if not
    foreach ($user in $users)
    {
        # Pull all info | select UPN
        $userInfo = Get-UserID -UserPrincipalName $user

        # Add the user to the group if they are not in the group
        if ($groupExistingMembers -contains $userInfo.UserPrincipalName)
        {
            Write-Host -ForegroundColor Yellow "UserIsInGroup: $($user) - $($group.DisplayName)"
        }
        else {
            Write-Host -ForegroundColor Yellow "AddingUserToGroup: User: $($userInfo.DisplayName) - Group: $($group.DisplayName)"
            try {
                New-MgGroupMember -GroupId $group.Id -DirectoryObjectId $userInfo.Id -ErrorAction Stop
                Write-Host -ForegroundColor Green "[SUCCESS] AddingUserToGroup: User: $($userInfo.DisplayName) - Group: $($group.DisplayName)"
            }
            catch {
                Write-Error "[FAIL] Error adding $($user) to $($group.Id)..."
                throw "ErrorAddingUserToGroup: $($user): $($userInfo.DisplayName)"
            }
        }
    }
    Write-Host -ForegroundColor Green "Task Completed."
    Write-Host -ForegroundColor Yellow "Disconnecting from Microsoft Graph..."
    Disconnect-MgGraph | Out-Null
    Write-Host -ForegroundColor Green "Disconnected from Microsoft Graph"
}

Start-Main
