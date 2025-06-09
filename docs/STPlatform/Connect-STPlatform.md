---
external help file: SupportTools-help.xml
Module Name: STPlatform
online version:
schema: 2.0.0
---

# Connect-STPlatform

## SYNOPSIS
Initializes modules and service connections for the specified environment.

## SYNTAX
```
Connect-STPlatform [-Mode] <String> [-InstallMissing] [-Vault <String>] [-ChaosMode] [<CommonParameters>]
```

## DESCRIPTION
Loads the necessary PowerShell modules and connects to Microsoft Graph,
Active Directory and Exchange depending on the chosen Mode. Use
`-InstallMissing` to automatically install any modules that are not
present. Required environment variables are loaded from SecretManagement
if missing; specify `-Vault` to override the default vault.

## EXAMPLES
### Example 1
```powershell
PS C:\> Connect-STPlatform -Mode Cloud
```
Loads the Microsoft Graph and Exchange Online modules and connects to both services.

### Example 2
```powershell
PS C:\> Connect-STPlatform -Mode Hybrid -InstallMissing
```
Installs any missing modules and establishes connections for a hybrid environment.

## PARAMETERS
### -Mode
Specifies the environment type. Valid values are `Cloud`, `Hybrid` and `OnPrem`.

### -InstallMissing
Automatically install missing modules when this switch is specified.

### -Vault
Secret vault name used to retrieve environment variables when they are
not already set.

### -ChaosMode
Simulate connection delays and random failures for testing. Equivalent to
setting the `ST_CHAOS_MODE` environment variable to `1`.

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable,
-Verbose, -WarningAction and -WarningVariable. For more information, see
[about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
When telemetry is enabled via `$env:ST_ENABLE_TELEMETRY = '1'`, each run records
the list of imported modules and the outcome of connection attempts. These
values appear in the Details field of the `Connect-STPlatform` metric as
`Modules` and `Connections`.
Use `-ChaosMode` or set `ST_CHAOS_MODE=1` to randomly delay or fail the initial
connection check for testing resilience.

## RELATED LINKS
