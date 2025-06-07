# Long-Term Stewardship

This guide explains how to keep the PowerShell modules healthy over time and prepare others to take over maintenance when needed.

## Succession Planning

- Keep the documentation in the `docs` folder current. Update examples whenever commands change.
- Archive resolved issues and tag open work with clear priority labels.
- Ensure at least two maintainers have rights to publish new module versions and manage CI secrets.

## Module Maturity

| Module            | Status       |
|-------------------|-------------|
| SupportTools      | Stable      |
| SharePointTools   | Beta        |
| ServiceDeskTools  | Experimental|

## Backup Strategy

- Store job histories, logs, and module state outside of this repository in a shared location.
- Periodically export any `$PSFramework` data stores and configuration files.
- Retain CI logs for at least 90 days to aid troubleshooting.

## Weekly Self-Tests

Set up a cron job or scheduled task to run `Invoke-Pester` across the repository every week. Review the results and update dependencies as required.
