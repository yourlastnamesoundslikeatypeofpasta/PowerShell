# ChaosTools Module

Provides helpers for chaos testing and fault injection.
Import the module with its manifest:

```powershell
Import-Module ./src/ChaosTools/ChaosTools.psd1
```

## Available Commands

| Command | Description | Example |
|---------|-------------|---------|
| `Invoke-ChaosTest` | Randomly delay or fail execution of a script block | `Invoke-ChaosTest -ScriptBlock { Get-Service } -FailureRate 0.2` |

Use these tools to validate that your automation gracefully handles transient failures.
Set the `CHAOSTOOLS_ENABLED` environment variable to `0` or `False` to disable
the random delay and failure behavior.
