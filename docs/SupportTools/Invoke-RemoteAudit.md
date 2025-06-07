---
external help file: SupportTools-help.xml
Module Name: SupportTools
online version:
schema: 2.0.0
---

# Invoke-RemoteAudit

## SYNOPSIS
Runs audit commands on remote computers using PowerShell remoting.

## SYNTAX
```
Invoke-RemoteAudit [-ComputerName] <String[]> [-AuditCommands <String[]>] [-Credential <PSCredential>] [<CommonParameters>]
```

## DESCRIPTION
Connects to each target computer, executes the specified audit commands (by default `Get-CommonSystemInfo` and `Get-FailedLogin`) and aggregates the results. Connection failures trigger a credential prompt and are logged via `Write-STLog`.

## EXAMPLES

### Example 1
```powershell
PS C:\> Invoke-RemoteAudit -ComputerName 'PC1','PC2'
```
Runs the default audits against PC1 and PC2.

## PARAMETERS
### -ComputerName
One or more computer names to audit.

### -AuditCommands
Names of audit commands to run remotely. Defaults to `Get-CommonSystemInfo` and `Get-FailedLogin`.

### -Credential
Credential to use for the remote session. If omitted and the initial connection fails, the cmdlet prompts for credentials.

## INPUTS
None

## OUTPUTS
System.Object

## RELATED LINKS
Get-CommonSystemInfo
Get-FailedLogin
