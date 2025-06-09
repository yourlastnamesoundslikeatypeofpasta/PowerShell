# ServiceDeskTools Module

Commands for interacting with the Service Desk ticketing API. **ServiceDeskTools is now considered Stable** and is fully supported for production use.

## Available Commands

| Command | Description | Example |
|---------|-------------|---------|
| `Get-SDTicket` | Retrieve an incident by ID | `Get-SDTicket -Id 42` |
| `Get-SDTicketHistory` | Retrieve audit history for an incident | `Get-SDTicketHistory -Id 42` |
| `New-SDTicket` | Create a new incident | `New-SDTicket -Subject "Printer issue" -Description "Cannot print" -RequesterEmail 'jane.doe@example.com'` |
| `Set-SDTicket` | Update an existing incident | `Set-SDTicket -Id 42 -Fields @{ status = 'Resolved' }` |
| `Add-SDTicketComment` | Add a comment to an incident | `Add-SDTicketComment -Id 42 -Comment 'Investigating'` |
| `Search-SDTicket` | Search incidents by keyword | `Search-SDTicket -Query 'printer'` |
| `Get-ServiceDeskAsset` | Retrieve an asset by ID | `Get-ServiceDeskAsset -Id 99` |
| `Get-ServiceDeskRelationship` | Retrieve asset relationships | `Get-ServiceDeskRelationship -AssetId 99 -Type 'component'` |
| `Get-ServiceDeskStats` | Summarize incidents by status | `Get-ServiceDeskStats -StartDate (Get-Date).AddDays(-1) -EndDate (Get-Date)` |
| `Set-SDTicketBulk` | Apply updates to multiple incidents | `Set-SDTicketBulk -Id 1,2,3 -Fields @{ status='Closed' }` |
| `Join-SDTicketToSPTask` | Add a related SharePoint task link | `Join-SDTicketToSPTask -TicketId 42 -TaskUrl 'https://contoso.sharepoint.com/tasks/1'` |
| `New-SimpleTicket` | Create a Service Desk incident with minimal parameters | `New-SimpleTicket -Subject 'Alert' -Description 'Issue detected' -RequesterEmail 'ops@example.com'` |
| `Export-SDConfig` | Output current Service Desk configuration to JSON | `Export-SDConfig -Path ./sdconfig.json` |

`SD_API_TOKEN` must be set in the environment. Optionally set `SD_BASE_URI` if your Service Desk API uses a custom URL. Use `SD_ASSET_BASE_URI` when assets are hosted on a separate endpoint.
For guidance on storing the token securely see [CredentialStorage.md](./CredentialStorage.md).

### Chaos Mode

All commands accept the `-ChaosMode` switch (or set the `ST_CHAOS_MODE` environment variable) to simulate delays and random request failures. Use this in development to test how your automation handles throttling and unreliable responses.
