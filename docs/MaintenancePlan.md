# MaintenancePlan Module

Import the module using its manifest:

```powershell
Import-Module ./src/MaintenancePlan/MaintenancePlan.psd1
```

## Available Commands

| Command | Description | Example |
|---------|-------------|---------|
| `New-MaintenancePlan` | Create a maintenance plan object. | `New-MaintenancePlan -Name Weekly -Tasks 'Clear-TempFile' -Schedule '0 2 * * Sun'` |
| `Export-MaintenancePlan` | Write a plan object to a JSON file. | `Export-MaintenancePlan -Plan $plan -Path plan.json` |
| `Import-MaintenancePlan` | Load a plan from JSON. | `Import-MaintenancePlan -Path plan.json` |
| `Invoke-MaintenancePlan` | Execute all tasks in a plan. | `Invoke-MaintenancePlan -Plan $plan` |

Use maintenance plans to group recurring tasks and store them as JSON files for sharing.
