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
| `Show-MaintenancePlan` | Display a summary of a plan. | `Show-MaintenancePlan -Plan $plan` |
| `Schedule-MaintenancePlan` | Register a task or generate cron. | `Schedule-MaintenancePlan -PlanPath plan.json -Cron '0 3 * * 0' -Name Weekly` |

### Scheduling
`Schedule-MaintenancePlan` registers a Windows scheduled task when running on Windows.
On Linux or macOS it outputs a cron line you can add with `crontab -e`.
When scheduling on Windows, the minute and hour fields are required in the cron
expression.  Optional day-of-month, month, and day-of-week fields are also
respected when creating the task.
