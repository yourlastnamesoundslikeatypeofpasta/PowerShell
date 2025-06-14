# Module Styling Guide

To keep console output consistent, all modules use helper functions from the `Logging` module.
The style mimics a modern terminal session with short, high contrast messages.

## Key Functions

- `Show-STPrompt` - Display the simulated shell prompt for the command being run.
- `Write-STStatus` - Emit status messages with structured prefixes (`[+]`, `[-]`, `[!]`, `[*]`, `[>]`, `[✔]`, `[✘]`).
- `Write-STDivider` - Separate logical sections with decorative lines.
- `Write-STBlock` - Present aligned information blocks.
- `Write-STClosing` - Print a closing banner when tasks finish.

## Example

```powershell
Show-STPrompt -Command './run-task.ps1 -Verbose'
Write-STStatus -Message 'Starting cleanup...' -Level INFO
Write-STDivider -Title 'ENUMERATING USERS'
Write-STBlock -Data @{ 'User'='svc-backend'; 'Domain'='corp.local'; 'IP'='10.10.10.5' }
Write-STClosing
```

## Banners with Color

`Out-STBanner` accepts a `-Color` parameter to emit the banner title using ANSI
color codes. Pass any standard console color name.

```powershell
Out-STBanner -Info (Show-LoggingBanner) -Color Red
```

All messages can also be logged to `%USERPROFILE%\SupportToolsLogs\supporttools.log` or `$env:ST_LOG_PATH`.
Use the `-Log` switch or `-Path` parameter of `Write-STLog` to override the location.
Use the `-Structured` parameter or set `ST_LOG_STRUCTURED=1` to output JSON lines with extra metadata.
See [Logging/RichLogFormat.md](./Logging/RichLogFormat.md) for an example of the structured log schema.
