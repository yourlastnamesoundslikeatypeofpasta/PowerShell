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

Chaos behavior can also be triggered in other modules. Set the `ST_CHAOS_MODE`
environment variable to `1` (or use the `-ChaosMode` switch where available) to
have commands automatically wrap API calls with `Invoke-ChaosTest`.

See [ChaosTools/Invoke-ChaosTest.md](ChaosTools/Invoke-ChaosTest.md) for full
command documentation.

Use these tools to validate that your automation gracefully handles transient failures.
