---
external help file: SupportTools-help.xml
Module Name: ConfigManagementTools
online version:
schema: 2.0.0
---

# Invoke-PostInstall

## SYNOPSIS
Executes the automated post installation script.

## SYNTAX

```
Invoke-PostInstall [[-Arguments] <Object[]>] [[-DomainName] <String>] [[-TranscriptPath] <String>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
Runs PostInstallScript.ps1 from the scripts folder, forwarding any
arguments provided.

## EXAMPLES

### Example 1
```powershell
PS C:\> Invoke-PostInstall -ConfigPath './install.json' -DomainName corp.example.com
```

Demonstrates typical usage of Invoke-PostInstall.

## PARAMETERS

### -Arguments
Arguments passed directly to the underlying script.

```yaml
Type: Object[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -DomainName
Fully qualified domain name used when joining the computer to the domain.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TranscriptPath
File path used to capture a transcript of this command's output and actions.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProgressAction
Specifies how progress is displayed.

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
