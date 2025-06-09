# Packaging and Distribution

This project can be packaged as a NuGet tool for internal feeds or the PowerShell Gallery.
The `SupportTools.nuspec` file defines a package that bundles the four modules in the `src` folder.
To build the package run:

```powershell
nuget pack SupportTools.nuspec -Version 1.3.0
```

Publish the resulting `.nupkg` to your Chocolatey or PowerShell Gallery repository.

Once published, install the entire suite on a fresh system using the helper script:

```powershell
# Load the modules directly from source
./scripts/Install-SupportTools.ps1
```

The script imports `Logging`, `Telemetry`, `IncidentResponseTools`, `SharePointTools`, `ServiceDeskTools` and `SupportTools` from the `src` directory.

## Signing Scripts

All PowerShell files can be signed in bulk using `Sign-STScripts.ps1`. Provide a certificate thumbprint and the path to the repository:

```powershell
./scripts/Sign-STScripts.ps1 -Thumbprint ABCDEF1234567890 -Path ./
```

To timestamp the signatures with an external service:

```powershell
./scripts/Sign-STScripts.ps1 -Thumbprint ABCDEF1234567890 -Path ./ -TimestampServer "http://timestamp.digicert.com"
```
