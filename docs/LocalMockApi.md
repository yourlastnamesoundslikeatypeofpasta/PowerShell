# Local Mock API

This short guide describes how to start a lightweight HTTP server that simulates minimal responses from Microsoft Graph and PnP.PowerShell APIs. Use it when developing or running the Pester tests offline.

## Starting the server

Run the script in the `scripts` folder:

```powershell
# Start the mock API on the default port 8080
./scripts/Start-MockApiServer.ps1
```

Specify a different port if needed:

```powershell
./scripts/Start-MockApiServer.ps1 -Port 9090
```

The server listens on `http://localhost:<port>/`. Requests to `/graph/` return a stubbed Graph response while `/pnp/` yields a stubbed PnP payload.

Stop the server with <kbd>Ctrl</kbd>+<kbd>C</kbd>.
