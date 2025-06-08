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

param(
    [string]$CsvPath,
    [string]$GroupName
)

. "$PSScriptRoot/../SupportToolsLoader.ps1"
Add-UserToGroup -CsvPath $CsvPath -GroupName $GroupName
