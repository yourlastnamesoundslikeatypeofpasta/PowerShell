# Module Styling Guide

To keep output consistent, the modules display short console messages using a retro
"90s hacker" style. All commands should call `Write-SPToolsHacker` to print
their status messages in bright green on a black background.

Example:

```powershell
Write-SPToolsHacker '>>> CLEANING FILES'
```

Include a message when starting work and another when the task completes so the
operator can follow along as scripts run.

Every message output through `Write-SPToolsHacker` is also written to
`%USERPROFILE%\SupportToolsLogs\supporttools.log` by default. Set the `ST_LOG_PATH`
environment variable or use `Write-STLog -Path` to log to a different file for
troubleshooting.
