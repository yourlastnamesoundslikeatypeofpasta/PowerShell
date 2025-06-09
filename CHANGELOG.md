# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
- Telemetry events recorded for `Connect-SPToolsOnline` ([SharePointTools docs](docs/SharePointTools.md#4-capture-telemetry-events))
- [`Sync-SupportTools`](docs/SupportTools/Sync-SupportTools.md) cmdlet to download modules from a feed
- Automatic registration of public functions in module manifests
- Option to persist structured logs via environment variable ([RichLogFormat](docs/Logging/RichLogFormat.md))
- [`Invoke-CompanyPlaceManagement`](docs/ConfigManagementTools/Invoke-CompanyPlaceManagement.md) command for Microsoft Places
- GitHub Actions workflows for caching modules and labeling PRs
- SupportTools cmdlets can inject custom logging and telemetry modules
- Detailed scenario documentation for the [SharePointTools](docs/SharePointTools.md) module
- SharePointTools module graduated from Beta to Stable with version 1.2.0
- `Out-STBanner` now accepts `-Color` to output ANSI colored titles ([ModuleStyleGuide](docs/ModuleStyleGuide.md#banners-with-color))
### Breaking Changes
- None in this release

### Changed
- Updated Pester invocation to align with v5 parameter requirements

### Fixed
- Build script now uses the latest artifact upload action

## [ServiceDeskTools 1.1.0] - 2024-04-29
### Added
- SupportsShouldProcess added to ticket management commands
- Additional Pester tests for `-WhatIf` scenarios
### Changed
- Documentation updated to reflect stable status

