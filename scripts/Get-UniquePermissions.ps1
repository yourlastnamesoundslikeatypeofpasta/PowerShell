<#
.SYNOPSIS
This script was developed to handle large SharePoint libraries that exceed the 5000 item limit by bypassing this restriction using PnP PowerShell cmdlets.

.DESCRIPTION
The primary objective of this script is to manage and process a SharePoint document library with more than 5000 unique items. SharePoint Online imposes a 5000 item limit on list views, which can present challenges when dealing with large libraries. This script leverages PnP PowerShell to retrieve and process items in a way that avoids the limitations imposed by SharePoint.

The script performs the following key actions:
1. Installs and imports the PnP PowerShell module for interacting with SharePoint Online.
2. Connects to the specified SharePoint site using interactive authentication.
3. Retrieves the root folder and its subfolders within the 'Shared Documents' library.
4. Traverses a specific folder hierarchy within the 'Sales' folder to retrieve all subfolders and their items.
5. Extracts the ListItemAllFields property for each item, which includes important metadata such as the item ID.
6. Retrieves detailed information for each item using its ID, focusing on properties such as 'HasUniqueRoleAssignments', 'ID', and 'FileRef'.
7. Identifies and processes items with unique role assignments, collecting their ID and file reference.
8. Outputs the list of items with unique role assignments in a table format for easy review.

This script is particularly useful for administrators and developers who need to manage large SharePoint libraries and ensure proper handling of items with unique permissions. By bypassing the 5000 item limit, it allows for efficient processing and analysis of extensive datasets.

.PARAMETER siteUrl
The URL of the SharePoint site containing the document library.

.PARAMETER libraries
The name of the document library to be processed.

.NOTES
This script requires tenant admin access and assumes the user has the necessary permissions to connect to the SharePoint site and access the specified library.

.EXAMPLE
.\ProcessLargeLibrary.ps1
This example runs the script, connecting to the predefined SharePoint site and processing the 'Shared Documents' library to identify and list items with unique role assignments.
#>


# Install the PnP PowerShell module for the current user
Install-Module Pnp.PowerShell -Scope CurrentUser

# Import the PnP PowerShell module locally
Import-Module Pnp.PowerShell -Scope Local

# Set information preference to continue
$InformationPreference = 'Continue'

# Define the SharePoint site URL (requires tenant admin access)
$siteUrl = "SITEURL"
Connect-PnPOnline -Url $siteUrl -Interactive

# Define the document library name
$libraries = "Shared Documents"

# Retrieve the document library
$libraryList = Get-PnPList -Identity $libraries

# Get the root folder of the document library
$sharedDocumentsLibrary = Get-PnPFolder -ListRootFolder $libraries
$sharePointFolders = $sharedDocumentsLibrary | Get-PnPFolderInFolder

# Traverse the 'Sales' folder hierarchy within 'Shared Documents' library
$salesSharePointFolder = $sharePointFolders[8]
$salesSharePointFolderLvl2 = $salesSharePointFolder | Get-PnPFolderInFolder
$salesSharePointFolderLvl3Private = $salesSharePointFolderLvl2 | Get-PnPFolderInFolder
$salesSharePointFolderLvl42024Sales = $salesSharePointFolderLvl3Private[7] | Get-PnPFolderInFolder

# Get all folders within the specified sales folder recursively
$salesSharePointFolderLvl42024SalesALLFOLDERS = $salesSharePointFolderLvl42024Sales | Get-PnPFolderItem -Recursive -ItemType Folder -Verbose

# Initialize a list to hold all items with ListItemAllFields property
Write-Information -MessageData "Getting PnpProperties..."
$itemsWithAllListItemFieldsList = [System.Collections.Generic.List[object]]::new()

# Loop through each folder to get its ListItemAllFields property
foreach ($salesSharePointFolderLvl42024SalesALLFOLDER in $salesSharePointFolderLvl42024SalesALLFOLDERS)
{
    $itemListItemAllFields = Get-PnPProperty -ClientObject $salesSharePointFolderLvl42024SalesALLFOLDER -Property ListItemAllFields
    $itemsWithAllListItemFieldsList.Add($itemListItemAllFields)
}

# Initialize a list to hold all items with specific fields
Write-Information -MessageData "Getting PnpListItems..."
$items = [System.Collections.Generic.List[object]]::new()

# Loop through each item to get its ListItemAllFields properties using the retrieved ID
foreach ($item in $itemsWithAllListItemFieldsList)
{
    try {
        $itemWithID = Get-PnPListItem -List $libraryList -Id $item.Id -Fields "HasUniqueRoleAssignments", "ID", "FileRef"
        $items.Add($itemWithID)
    }
    catch {
        Write-Warning "ITEM ID: $($item.Id): MessageTooLarge"
    }
}

# Initialize a list to hold items with unique role assignments
$uniqueRolesList = [System.Collections.Generic.List[object]]::new()

# Loop through each item to check for unique role assignments and process them
foreach ($item in $items)
{
    Write-Information -MessageData "Processing $($item.FieldValues.FileRef)"
    if ($item.HasUniqueRoleAssignments)
    {
        Write-Warning "File has unique role assignments: $($item.FieldValues.FileRef)"
        $customObject = [pscustomobject]@{
            ID = $item.FieldValues.ID
            FileRef = $item.FieldValues.FileRef
        }
        $uniqueRolesList.Add($customObject)
    }
}

# Return the list of items with unique role assignments
return $uniqueRolesList
