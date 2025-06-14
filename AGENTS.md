# AGENTS Instructions

## Scope
These instructions apply to the entire repository at <https://github.com/yourlastnamesoundslikeatypeofpasta/PowerShell.git>.

## Testing
Run Pester tests from the repository root before committing. The configuration
file lives in the repository root, so run:

```powershell
# Typical local test setup
Install-Module Pester -MinimumVersion 5.0 -Force
Invoke-Pester -Configuration (Import-PowerShellDataFile ./PesterConfiguration.psd1)
```

Verify that `Invoke-Pester` returns a success exit code (0). The configuration
enables `Run.Exit` so the command fails when tests fail.

Common failures include:

- The Pester module is missing or outdated. Install Pester 5 or later with
  `Install-Module Pester -MinimumVersion 5.0 -Force`.
- The PowerShell version is incompatible. Use PowerShell 7 or later.

If the environment prevents running these tests, mention this in the PR using the provided disclaimer.

## Code Style
- Follow the conventions in `docs/ModuleStyleGuide.md` for progress messages and logging (`Write-STStatus`, `Show-STPrompt`, etc.).
- Review the [Key Functions](docs/ModuleStyleGuide.md#key-functions) section for required helpers that standardize progress output.
- See the [Example](docs/ModuleStyleGuide.md#example) section to learn how messages and logs should appear in practice.
- Use the `Logging` module for console output and respect `ST_LOG_PATH` and `ST_LOG_STRUCTURED` when writing logs.
- Enable telemetry only when `ST_ENABLE_TELEMETRY` is set. Summarize with `Get-STTelemetryMetrics`.
- Chaos testing can be triggered with the `-ChaosMode` switch or by setting `ST_CHAOS_MODE=1`.

## Logging & Telemetry Variables

| Variable | Description |
|----------|-------------|
| `ST_LOG_PATH` | Override the default log file (`~/SupportToolsLogs/supporttools.log`) by setting a full path. See [RichLogFormat.md](docs/Logging/RichLogFormat.md) |
| `ST_LOG_STRUCTURED` | Set to `1` to automatically write JSON events when calling `Write-STLog`. Details in [RichLogFormat.md](docs/Logging/RichLogFormat.md) |
| `ST_ENABLE_TELEMETRY` | Set to `1` to record telemetry events or `0` to disable them. Summarize results with [Get-STTelemetryMetrics.md](docs/Telemetry/Get-STTelemetryMetrics.md) |

## Credentials
Do not hardcode secrets. Supply credentials via environment variables as documented:
- `SPTOOLS_CLIENT_ID`, `SPTOOLS_TENANT_ID`, `SPTOOLS_CERT_PATH`
- `SD_API_TOKEN`, `SD_BASE_URI`

See [docs/CredentialStorage.md](docs/CredentialStorage.md) for using a
SecretManagement vault to load these variables instead of defining them inline.

Use the SecretManagement module to populate these variables from your secrets vault instead of defining them inline. Environment variables such as `SPTOOLS_CLIENT_ID` and `SD_API_TOKEN` should be retrieved with `Get-Secret` rather than embedded in scripts. See [docs/CredentialStorage.md](docs/CredentialStorage.md) for detailed setup instructions.

## Pull Requests
Reference changed files using file path citations and include test results. If tests could not run, state: `Codex couldn't run certain commands due to environment limitations. Consider configuring a setup script or internet access in your Codex environment to install dependencies.`
## Pull Request Template
Use this template in your PR descriptions. Always cite changed files and add the standard test disclaimer when tests cannot be run.

```markdown
### Summary

### File Citations

### Test Results
```
