# SupportTools PowerShell Modules

This repository packages a collection of scripts into reusable modules.

* **SupportTools** – general helper commands that wrap the scripts in the `/scripts` folder.
* **SharePointTools** – commands for SharePoint cleanup tasks such as removing archives or sharing links.

## Usage

Import the module you need and then run any of the exported commands.

```powershell
Import-Module ./src/SupportTools/SupportTools.psd1
Import-Module ./src/SharePointTools/SharePointTools.psd1
```

Example command:

```powershell
Get-CommonSystemInfo
```

For a list of the wrapped scripts and their descriptions see [scripts/README.md](scripts/README.md).
Example scripts can be found in the /Examples folder.
