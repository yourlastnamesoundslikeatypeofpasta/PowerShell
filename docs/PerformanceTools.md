# PerformanceTools Module

Provides helper commands for measuring script performance. Import the module using its manifest:

```powershell
Import-Module ./src/PerformanceTools/PerformanceTools.psd1
```

Performance logs are written to `%USERPROFILE%\SupportToolsLogs\supporttools.log` unless `$env:ST_LOG_PATH` is set. Enable `ST_LOG_STRUCTURED=1` for JSON output. See [Logging/RichLogFormat.md](Logging/RichLogFormat.md).

## Available Commands

| Command | Description |
|---------|-------------|
| `Measure-STCommand` | Execute a script block and report duration, CPU time and memory delta. |
| `Invoke-PerformanceAudit` | Collect system metrics and optionally open a Service Desk ticket when thresholds are exceeded. |
