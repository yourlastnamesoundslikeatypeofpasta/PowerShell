# MaintenancePlan Module

Import the module using its manifest:

```powershell
Import-Module ./src/MaintenancePlan/MaintenancePlan.psd1
```

## Available Commands

| Command | Description | Example |
|---------|-------------|---------|
| `New-MaintenancePlan` | Create a maintenance plan object. | `New-MaintenancePlan -Name Weekly -Steps @('Cleanup.ps1','Backup-DB')` |
| `Export-MaintenancePlan` | Save a plan to a JSON file. | `$plan | Export-MaintenancePlan -Path plan.json` |
| `Import-MaintenancePlan` | Load a plan from JSON. | `Import-MaintenancePlan -Path plan.json` |
| `Invoke-MaintenancePlan` | Execute plan steps. | `Invoke-MaintenancePlan -Plan $plan` |
