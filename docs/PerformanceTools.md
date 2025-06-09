# PerformanceTools Module

Provides helper commands for measuring script performance. Import the module using its manifest:

```powershell
Import-Module ./src/PerformanceTools/PerformanceTools.psd1
```

## Available Commands

| Command | Description |
|---------|-------------|
| `Measure-STCommand` | Execute a script block and report duration, CPU time and memory delta. |
| `Invoke-PerformanceAudit` | Collect system metrics and optionally open a Service Desk ticket when thresholds are exceeded. Uses `Get-Counter` on Windows and falls back to platform tools when available. |
