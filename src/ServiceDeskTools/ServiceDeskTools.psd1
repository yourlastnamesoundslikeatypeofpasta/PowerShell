@{
    RootModule = 'ServiceDeskTools.psm1'
    ModuleVersion = '1.4.0'
    GUID = 'b6b7e080-4ad4-4d58-8b8c-000000000003'
    Author = 'Contoso'
    Description = 'Commands for interacting with the Service Desk ticketing system.'
    RequiredModules = @('Logging','Telemetry')
    PrivateData = @{ PSData = @{ Tags = @('PowerShell','ServiceDesk','Internal') } }
    FunctionsToExport = @(
        'Add-SDTicketComment','Export-SDConfig','Get-SDTicket',
        'Get-SDTicketHistory','Get-SDUser','Get-ServiceDeskAsset',
        'Get-ServiceDeskRelationship','Get-ServiceDeskStats',
        'Link-SDTicketToSPTask','New-SDTicket','Search-SDTicket',
        'Set-SDTicket','Set-SDTicketBulk','Submit-Ticket'
    )
}
