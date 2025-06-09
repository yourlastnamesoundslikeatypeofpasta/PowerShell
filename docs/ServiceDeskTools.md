# ServiceDeskTools Module

Commands for interacting with the Service Desk ticketing API. **ServiceDeskTools is now considered Stable** and is fully supported for production use.

## Available Commands

| Command | Description | Example |
|---------|-------------|---------|
| `Get-SDTicket` | Retrieve an incident by ID | `Get-SDTicket -Id 42` |
| `Get-SDTicketHistory` | Retrieve audit history for an incident | `Get-SDTicketHistory -Id 42` |
| `New-SDTicket` | Create a new incident | `New-SDTicket -Subject "Printer issue" -Description "Cannot print" -RequesterEmail 'jane.doe@example.com'` |
| `Set-SDTicket` | Update an existing incident | `Set-SDTicket -Id 42 -Fields @{ status = 'Resolved' }` |
| `Search-SDTicket` | Search incidents by keyword | `Search-SDTicket -Query 'printer'` |
| `Set-SDTicketBulk` | Apply updates to multiple incidents | `Set-SDTicketBulk -Id 1,2,3 -Fields @{ status='Closed' }` |
| `Get-ServiceDeskAsset` | Retrieve an asset by ID | `Get-ServiceDeskAsset -Id 55` |
| `Link-SDTicketToSPTask` | Add a related SharePoint task link | `Link-SDTicketToSPTask -TicketId 42 -TaskUrl 'https://contoso.sharepoint.com/tasks/1'` |
| `Submit-Ticket` | Create a Service Desk incident with minimal parameters | `Submit-Ticket -Subject 'Alert' -Description 'Issue detected' -RequesterEmail 'ops@example.com'` |

`SD_API_TOKEN` must be set in the environment. Optionally set `SD_BASE_URI` or `SD_ASSET_BASE_URI` if your Service Desk API uses custom URLs for incidents or assets.
For guidance on storing the token securely see [CredentialStorage.md](./CredentialStorage.md).

### Chaos Mode

All commands accept the `-ChaosMode` switch (or set the `ST_CHAOS_MODE` environment variable) to simulate delays and random request failures. Use this in development to test how your automation handles throttling and unreliable responses.
