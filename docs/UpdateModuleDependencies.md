# Update-ModuleDependencies.ps1

This maintenance script updates all module dependencies referenced in `SupportTools.nuspec`.
It uses `Update-Module` to pull the latest versions from your configured repositories.
After each module is updated the script validates the newest manifest with `Get-AuthenticodeSignature`.
Results are recorded using `Write-STLog` so you can review success or failure messages in the log file.

Run the script from the repository root:

```powershell
./scripts/Update-ModuleDependencies.ps1
```

Modules are skipped when they cannot be updated or their manifest is not found. Signature failures are written as error entries.
