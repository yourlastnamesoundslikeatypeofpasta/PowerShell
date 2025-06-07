---
external help file: SupportTools-help.xml
Module Name: SupportTools
online version:
schema: 2.0.0
---

# New-STProfile

## SYNOPSIS
Creates or updates a saved parameter profile.

## SYNTAX
```powershell
New-STProfile -TaskCategory <String> -Name <String> -Command <String> [-Parameters <Hashtable>] [<CommonParameters>]
```

## DESCRIPTION
`New-STProfile` stores the provided command name and parameter values in a JSON file. Profiles are organized by task category so multiple profiles can be saved for different recurring scenarios.

## EXAMPLES
### Example 1
```powershell
New-STProfile -TaskCategory Audit -Name Weekly -Command Invoke-Audit -Parameters @{ Targets='Servers'; ReportPath='audit.csv' }
```
Creates a profile named `Weekly` in the `Audit` category.

## PARAMETERS
### -TaskCategory
Logical grouping for the profile (e.g. Audit, Performance).

### -Name
Name of the profile.

### -Command
Command to run when invoking the profile.

### -Parameters
Hashtable of parameters for the command.

### CommonParameters
This cmdlet supports the common parameters. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS
None.

## OUTPUTS
None.

## NOTES
Profiles are stored under `$env:ST_PROFILE_PATH` if set; otherwise they are saved to `~/SupportToolsProfiles`.

## RELATED LINKS
[Invoke-STProfile](./Invoke-STProfile.md)
