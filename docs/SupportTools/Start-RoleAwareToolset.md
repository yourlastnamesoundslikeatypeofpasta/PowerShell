---
external help file: SupportTools-help.xml
Module Name: SupportTools
online version:
schema: 2.0.0
---

# Start-RoleAwareToolset

## SYNOPSIS
Launches an interactive menu that exposes different options based on the user role.

## SYNTAX
```powershell
Start-RoleAwareToolset [[-UserRole] <String>] [[-TranscriptPath] <String>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Executes `RoleAwareToolset.ps1` from the `scripts` directory. When `-UserRole` is `Helpdesk` the menu displays only the Create Ticket option. For `Site Admin`, the menu exposes Group Membership Cleanup.

## EXAMPLES
### Example 1
```powershell
PS C:\> Start-RoleAwareToolset -UserRole "Helpdesk"
```
Runs the toolset for helpdesk staff.

## PARAMETERS
### -UserRole
Specifies the role context. Accepts `Helpdesk` or `Site Admin`.
```yaml
Type: String
Parameter Sets: (All)
```
### -TranscriptPath
Path to the transcript log.
```yaml
Type: String
Parameter Sets: (All)
```
