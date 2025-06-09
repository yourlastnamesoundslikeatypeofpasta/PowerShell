# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
- Telemetry events recorded for Connect-SPToolsOnline ([docs](docs/SharePointTools.md#4-capture-telemetry-events))
- `Sync-SupportTools` cmdlet to download modules from a feed ([docs](docs/SupportTools/Sync-SupportTools.md))
- Automatic registration of public functions in module manifests
- Option to persist structured logs via environment variable ([docs](docs/Logging/RichLogFormat.md))
- `Invoke-CompanyPlaceManagement` command for Microsoft Places ([docs](docs/ConfigManagementTools/Invoke-CompanyPlaceManagement.md))
- GitHub Actions workflows for caching modules and labeling PRs
- SupportTools cmdlets can inject custom logging and telemetry modules
- Detailed scenario documentation for the SharePointTools module ([docs](docs/SharePointTools.md))
- SharePointTools module graduated from Beta to Stable with version 1.2.0
- `Out-STBanner` now accepts `-Color` to output ANSI colored titles ([docs](docs/ModuleStyleGuide.md#banners-with-color))

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

