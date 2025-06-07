# ChaosTools Module

Utilities for chaos engineering and fault injection. Import using its manifest:

```powershell
Import-Module ./src/ChaosTools/ChaosTools.psd1
```

## Available Commands

| Command | Description |
|---------|-------------|
| `Invoke-ChaosTest` | Run randomized delays and optional errors to validate retry logic. |

Use the `-ChaosMode` switch or set `ST_CHAOS_MODE=1` to enable failures.
