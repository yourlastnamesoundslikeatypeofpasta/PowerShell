# Test Improvement Tasks

This document lists proposed tasks to mature the repository's testing approach.

- **Add Pester tests for untested scripts** such as `CleanupArchive.ps1`, `CleanupTempFiles.ps1`, `Configure-SharePointTools.ps1`, `Get-UniquePermissions.ps1`, `Process-TerminationTickets.ps1`, `RollbackArchive.ps1`, `SimpleCountdown.ps1`, `SupportToolsMenu.ps1`, and `Sync-SDTickets.ps1`.
- **Expand ServiceDeskTools scenario coverage** by creating end-to-end tests around ticket workflows, asset lookups, and relationship queries.
- **Introduce integration tests using the local mock API** with `Start-MockApiServer.ps1` to validate Graph and SharePoint interactions offline.
- **Run the test workflow on Windows in addition to Ubuntu** to ensure modules behave consistently across platforms.
- **Schedule weekly self-tests** through an automated workflow to keep dependencies current and catch regressions.
- **Enforce a minimum code-coverage threshold** by parsing `coverage.xml` and failing the build if coverage drops below an agreed level (e.g., 80%).
- **Add negative tests for error helpers and script failures** to validate functions like `New-STErrorRecord` and prevent call-depth issues.
- **Broaden environment variable combinations** to confirm that logging and telemetry variables work together in different configurations.
- **Test long-running and polling scripts** such as `Sync-SDTickets.ps1` by mocking time progression and verifying loop behavior.
- **Cover interactive utilities** like `SupportToolsMenu.ps1` and `SimpleCountdown.ps1` using mocked `Read-Host` input to automate these interfaces.
