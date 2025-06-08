---
external help file: SupportTools-help.xml
Module Name: IncidentResponseTools
online version:
schema: 2.0.0
---

# Invoke-RemoteAudit

## SYNOPSIS
Collects common system information from remote computers.

## SYNTAX
```
Invoke-RemoteAudit [-ComputerName] <String[]> [-Credential <PSCredential>] [-UseSSL] [-Port <Int>]
 [<CommonParameters>]
```

## DESCRIPTION
Uses PowerShell remoting to run `Get-CommonSystemInfo` on each specified computer. The command
returns an object for every target containing either the collected information or the error
encountered.

## EXAMPLES

### Example 1
```powershell
PS C:\> Invoke-RemoteAudit -ComputerName PC1,PC2
```
Collect system information from two remote computers.

## PARAMETERS
### -ComputerName
One or more computer names to audit.

### -Credential
Credential for the remote session.

### -UseSSL
Use HTTPS/SSL for the remote session.

### -Port
Alternate remoting port. Defaults to `5985`.

### CommonParameters
This cmdlet supports the common parameters. For more information, see
[about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS
## OUTPUTS
### System.Management.Automation.PSCustomObject
Each object contains `ComputerName`, `Success`, and either `Info` or `Error` fields.

## NOTES
## RELATED LINKS
Get-CommonSystemInfo
