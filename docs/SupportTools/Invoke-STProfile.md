---
external help file: SupportTools-help.xml
Module Name: SupportTools
online version:
schema: 2.0.0
---

# Invoke-STProfile

## SYNOPSIS
Executes a previously saved SupportTools profile.

## SYNTAX
```powershell
Invoke-STProfile -TaskCategory <String> -Name <String> [-PassThru] [<CommonParameters>]
```

## DESCRIPTION
`Invoke-STProfile` loads the specified profile and runs the stored command with its saved parameters. Logging and telemetry events are emitted for auditing.

## EXAMPLES
### Example 1
```powershell
Invoke-STProfile -TaskCategory Audit -Name Weekly
```
Runs the command stored in the `Weekly` profile from the `Audit` category.

## PARAMETERS
### -TaskCategory
Category under which the profile was saved.

### -Name
Name of the profile to execute.

### -PassThru
Return the command's output instead of suppressing it.

### CommonParameters
This cmdlet supports the common parameters. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS
None.

## OUTPUTS
Outputs of the invoked command are returned when `-PassThru` is specified.

## NOTES
Profiles are read from `$env:ST_PROFILE_PATH` or `~/SupportToolsProfiles` by default.

## RELATED LINKS
[New-STProfile](./New-STProfile.md)
