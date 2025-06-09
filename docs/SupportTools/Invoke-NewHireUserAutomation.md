---
external help file: SupportTools-help.xml
Module Name: SupportTools
online version:
schema: 2.0.0
---

# Invoke-NewHireUserAutomation

## SYNOPSIS
Creates Entra ID users from new hire Service Desk tickets.

## SYNTAX
```powershell
Invoke-NewHireUserAutomation [[-PollMinutes] <Int32>] [-Once] [[-TranscriptPath] <String>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Wraps the `Create-NewHireUser.ps1` script. The command searches the Service Desk for tickets containing the phrase "new hire" and creates accounts using the details stored in each ticket's custom fields.

## EXAMPLES
### Example 1
```powershell
PS C:\> Invoke-NewHireUserAutomation -Once
```
Processes new hire tickets a single time and exits.

## PARAMETERS
### -PollMinutes
Interval between ticket checks in minutes. Default is `5`.

### -Once
Run only a single polling cycle then exit.

### -TranscriptPath
Optional path to save a transcript log.

## INPUTS
None

## OUTPUTS
None

## ALIASES
NewHire-Automation

