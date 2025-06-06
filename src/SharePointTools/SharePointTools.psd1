@{
    RootModule = 'SharePointTools.psm1'
    ModuleVersion = '1.0.0'
    GUID = 'b6b7e080-4ad4-4d58-8b8c-000000000002'
    Author = 'Contoso'
    Description = 'SharePoint cleanup helper commands.'
    FunctionsToExport = @(
        'Invoke-YFArchiveCleanup',
        'Invoke-IBCCentralFilesArchiveCleanup',
        'Invoke-MexCentralFilesArchiveCleanup',
        'Invoke-ArchiveCleanup',
        'Invoke-YFFileVersionCleanup',
        'Invoke-IBCCentralFilesFileVersionCleanup',
        'Invoke-MexCentralFilesFileVersionCleanup',
        'Invoke-FileVersionCleanup',
        'Invoke-SharingLinkCleanup',
        'Invoke-YFSharingLinkCleanup',
        'Invoke-IBCCentralFilesSharingLinkCleanup',
        'Invoke-MexCentralFilesSharingLinkCleanup',
        'Get-SPToolsSettings',
        'Get-SPToolsSiteUrl',
        'Add-SPToolsSite',
        'Set-SPToolsSite',
        'Remove-SPToolsSite',
        'Get-SPToolsLibraryReport',
        'Get-SPToolsAllLibraryReports',
        'Get-SPToolsRecycleBinReport',
        'Clear-SPToolsRecycleBin',
        'Get-SPToolsAllRecycleBinReports'
    )
}
