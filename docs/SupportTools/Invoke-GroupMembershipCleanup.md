---
external help file: SupportTools-help.xml
Module Name: SupportTools
online version:
schema: 2.0.0
---

# Invoke-GroupMembershipCleanup

## SYNOPSIS
Removes disabled members from a Microsoft 365 group.

## SYNTAX
```powershell
Invoke-GroupMembershipCleanup [[-Arguments] <Object[]>] [[-TranscriptPath] <String>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Wraps the `Cleanup-GroupMembership.ps1` script located in the `scripts` folder. All provided parameters are passed through to that script.

## EXAMPLES
### Example 1
```powershell
PS C:\> Invoke-GroupMembershipCleanup -GroupName "Team"
```
Demonstrates typical usage of Invoke-GroupMembershipCleanup.

## PARAMETERS
### -Arguments
Arguments forwarded to the script.
```yaml
Type: Object[]
Parameter Sets: (All)
```
### -TranscriptPath
Path for the transcript log file.
```yaml
Type: String
Parameter Sets: (All)
```
