@{
    RootModule = 'Logging.psm1'
    ModuleVersion = '1.4.0'
    GUID = 'b6b7e080-4ad4-4d58-8b8c-000000000010'
    Author = 'Contoso'
    Description = 'Provides centralized logging utilities for all modules.'
    PrivateData = @{ PSData = @{ Tags = @('PowerShell','Logging','Internal') } }
    # Export only the public functions
    FunctionsToExport = @(
        'Write-STLog',
        'Write-STRichLog',
        'Write-STStatus',
        'Show-STPrompt',
        'Write-STDivider',
        'Write-STBlock',
        'Write-STClosing',
        'Show-LoggingBanner'
    )
}
