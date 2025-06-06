# ServiceDeskTools Module

Commands for interacting with the Service Desk ticketing API.

## Available Commands

| Command | Description | Example |
|---------|-------------|---------|
| `Get-SDTicket` | Retrieve an incident by ID | `Get-SDTicket -Id 42` |
| `New-SDTicket` | Create a new incident | `New-SDTicket -Subject "Printer issue" -Description "Cannot print" -RequesterEmail 'jane.doe@example.com'` |
| `Set-SDTicket` | Update an existing incident | `Set-SDTicket -Id 42 -Fields @{ status = 'Resolved' }` |

`SD_API_TOKEN` must be set in the environment. Optionally set `SD_BASE_URI` if your Service Desk API uses a custom URL.
