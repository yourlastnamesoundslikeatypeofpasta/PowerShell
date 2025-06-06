<#
.SYNOPSIS
This script connects to a SharePoint Online site, navigates to an archived directory, and deletes all files and folders within that directory.

.DESCRIPTION
The script performs the following actions:
1. Imports the PnP PowerShell module for interacting with SharePoint Online.
2. Connects to a specified SharePoint Online site using interactive authentication.
3. Navigates to the 'Shared Documents' library and drills down to the 'zzz_Archive_Production' folder.
4. Organizes the items within 'zzz_Archive_Production' into separate lists for files and folders.
5. Deletes all files and folders within the 'zzz_Archive_Production' directory.
6. Ensures that only items within the 'zzz_Archive_Production' directory are deleted by checking their paths.

The script includes a helper function, `Test-PathIsArchived`, to verify that the items being processed are indeed within the archived directory. If an item is not within the archived directory, an error is thrown, and the script stops.

.PARAMETER siteUrl
The URL of the SharePoint site containing the document library.

.PARAMETER libraries
The name of the document library to be processed.

.NOTES
This script requires tenant admin access and assumes the user has the necessary permissions to connect to the SharePoint site and access the specified library. It is intended for use in scenarios where large numbers of files and folders need to be managed and cleaned up efficiently.

.EXAMPLE
.\CleanUpArchive.ps1
This example runs the script, connecting to the predefined SharePoint site and processing the 'Shared Documents' library to delete all items within the 'zzz_Archive_Production' folder.
#>

# Import the PnP PowerShell module
Import-Module Pnp.PowerShell
$InformationPreference = 'Continue'

function Test-PathIsArchived {
    <#
    .SYNOPSIS
        Validates that an item resides in the archive directory.
    .DESCRIPTION
        Throws an error if the provided item is outside of the
        zzz_Archive_Production folder. Used as a guard before deleting files.
    .PARAMETER ArchivedFileItem
        The SharePoint item object to validate.
    #>
    param(
        [object]$ArchivedFileItem
    )
    $DirectoryPath = 'zzz_Archive_Production'
    if (!$ArchivedFileItem.ServerRelativeUrl.Contains($DirectoryPath))
    {
        Write-Error -Message "This is not an archived directory!"
        throw "STOPPING!"
    }
}

# Connect to SharePoint Online
$SiteUrl = "SITEURL"
Connect-PnPOnline -Url $SiteUrl -Interactive
$Libraries = "Shared Documents"
Write-Debug -Message "Connected to SharePoint..."

# Navigate to the root folder of the document library
$SharedDocumentsLibrary = Get-PnPFolder -ListRootFolder $Libraries
$SharePointFolders = $SharedDocumentsLibrary | Get-PnPFolderInFolder
Write-Debug -Message ($SharedDocumentsLibrary | Format-Table | Out-String)
Write-Debug -Message ($SharePointFolders | Format-Table | Out-String)

# Navigate deeper into the folder structure
$ProductionSharePointFolders = $SharePointFolders[2]
$ProductionSharePointSubfolder = $ProductionSharePointFolders | Get-PnPFolderInFolder
Write-Debug -Message ($ProductionSharePointFolders | Format-Table | Out-String)
Write-Debug -Message ($ProductionSharePointSubfolder | Format-Table | Out-String)

# Navigate to the 'zzz_Archive_Production' folder
$ZzzArchiveProductionSharePointFolder = $ProductionSharePointSubfolder[7]
$ZzzArchiveProductionSharePointFolderItems = $ZzzArchiveProductionSharePointFolder | Get-PnPFolderItem -Recursive -Verbose
Write-Debug -Message ($ZzzArchiveProductionSharePointFolder | Format-Table | Out-String)
Write-Debug -Message ($ZzzArchiveProductionSharePointFolderItems | Format-Table | Out-String)

# Organize items into separate lists for files and folders
[System.Collections.Generic.List[object]]$Folders = $ZzzArchiveProductionSharePointFolderItems | where {$_.GetType().Name -eq "Folder"}
[System.Collections.Generic.List[object]]$Files = $ZzzArchiveProductionSharePointFolderItems | where {$_.GetType().Name -eq "File"}

# Delete all files
foreach ($file in $Files)
{
    Test-PathIsArchived -ArchivedFileItem $file
    Remove-PnPFile -ServerRelativeUrl $file.ServerRelativeUrl -Force
    Write-Information -MessageData "DeletedFile: $($file.ServerRelativeUrl)"
}

# Delete folders
while ($Folders)
{
    $folder = $Folders | Get-Random
    try {
        Test-PathIsArchived -ArchivedFileItem $folder
        Remove-PnPFolder -Name $folder.Name -Folder $folder.ParentFolder -Force
        Write-Verbose -Message "Deleted: $($folder.Name)"
        $Folders.Remove($folder) | Out-Null
    }
    catch {
        Write-Error "Error: $($_.Exception.Message)"
    }
}

# Delete root folders and files within 'zzz_Archive_Production'
foreach ($folder in $ZzzArchiveProductionSharePointFolder)
{
    if ($folder.Name -eq "zzz_Archive_Production")
    {
        Continue
    }
    Test-PathIsArchived -ArchivedFileItem $folder
    if ($folder.GetType().Name -eq 'File')
    {
        Remove-PnPFile -ServerRelativeUrl $folder.ServerRelativeUrl -Force
        Write-Verbose -Message "RemovedFile: $($folder.ServerRelativeUrl)"
    }
    if ($folder.GetType().Name -eq 'Folder')
    {
        Remove-PnPFolder -Name $folder.Name -Folder $folder.ParentFolder -Force
        Write-Verbose -Message "RemovedFile: $($folder.ServerRelativeUrl)"
    }
}
