# AGENTS Instructions

## Scope
These instructions apply to the entire repository.

## Testing
Run Pester tests from the repository root before committing:

```powershell
Invoke-Pester -Configuration ./PesterConfiguration.psd1
```

If the environment prevents running these tests, mention this in the PR using the provided disclaimer.

## Code Style
- Follow the conventions in `docs/ModuleStyleGuide.md` for progress messages and logging (`Write-STStatus`, `Show-STPrompt`, etc.).
- Review the [Key Functions](docs/ModuleStyleGuide.md#key-functions) section for required helpers that standardize progress output.
- See the [Example](docs/ModuleStyleGuide.md#example) section to learn how messages and logs should appear in practice.
- Use the `Logging` module for console output and respect `ST_LOG_PATH` and `ST_LOG_STRUCTURED` when writing logs.
- Enable telemetry only when `ST_ENABLE_TELEMETRY` is set. Summarize with `Get-STTelemetryMetrics`.
- Chaos testing can be triggered with the `-ChaosMode` switch or by setting `ST_CHAOS_MODE=1`.

## Credentials
Do not hardcode secrets. Supply credentials via environment variables as documented:
- `SPTOOLS_CLIENT_ID`, `SPTOOLS_TENANT_ID`, `SPTOOLS_CERT_PATH`
- `SD_API_TOKEN`, `SD_BASE_URI`

## Pull Requests
Reference changed files using file path citations and include test results. If tests could not run, state: `Codex couldn't run certain commands due to environment limitations. Consider configuring a setup script or internet access in your Codex environment to install dependencies.`
