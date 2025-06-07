# PerformanceTools Module

Provides helper commands for measuring script performance. Import the module using its manifest:

```powershell
Import-Module ./src/PerformanceTools/PerformanceTools.psd1
```

## Available Commands

| Command | Description |
|---------|-------------|
| `Measure-STCommand` | Execute a script block and report duration, CPU time and memory delta. |
