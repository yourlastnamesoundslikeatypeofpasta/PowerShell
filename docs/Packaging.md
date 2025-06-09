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
# Pin SupportTools to a specific version
./scripts/Install-SupportTools.ps1 -SupportToolsVersion 1.3.0
```

The script downloads `Logging`, `SharePointTools`, `ServiceDeskTools` and the specified version of `SupportTools` from the gallery. If the gallery can't be reached it imports the local copies from `src` instead.

## Signing Scripts

All PowerShell files can be signed in bulk using `Sign-STScripts.ps1`. Provide a certificate thumbprint and the path to the repository:

```powershell
./scripts/Sign-STScripts.ps1 -Thumbprint ABCDEF1234567890 -Path ./
```

To timestamp the signatures with an external service:

```powershell
./scripts/Sign-STScripts.ps1 -Thumbprint ABCDEF1234567890 -Path ./ -TimestampServer "http://timestamp.digicert.com"
```
