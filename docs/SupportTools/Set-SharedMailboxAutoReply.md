---
external help file: SupportTools-help.xml
Module Name: SupportTools
online version:
schema: 2.0.0
---

# Set-SharedMailboxAutoReply

## SYNOPSIS
Configures automatic replies for a shared mailbox.

## SYNTAX

```
Set-SharedMailboxAutoReply [-MailboxIdentity] <String> [-StartTime] <DateTime> [-EndTime] <DateTime>
 [-InternalMessage] <String> [[-ExternalMessage] <String>] [[-ExternalAudience] <String>] [-AdminUser] <String>
 [-UseWebLogin] [[-TranscriptPath] <String>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Wraps a script that manages Exchange Online auto-reply settings for a
shared mailbox.
All specified parameters are forwarded to the script.

## EXAMPLES

### Example 1
```powershell
PS C:\> $start = Get-Date '2025-06-02T00:00:00'
$end   = Get-Date '2025-06-09T23:59:59'

Set-SharedMailboxAutoReply -MailboxIdentity 'parts@yellowfin.com'     -StartTime $start -EndTime $end     -InternalMessage 'Apologies, but I'm out of the office from 6/2 - 6/9 and will return on 6/10. I will be responding to all emails and phone calls upon my return. If you need immediate assistance, please reach out to Jay Wagner at ext 312.'     -ExternalMessage 'Apologies, but I'm out of the office from 6/2 - 6/9 and will return on 6/10. I will be responding to all emails and phone calls upon my return. If you need immediate assistance, please reach out to Jay Wagner at ext 312.'     -AdminUser 'youradmin@yourdomain.com'
```

Demonstrates typical usage of Set-SharedMailboxAutoReply.

## PARAMETERS

### -MailboxIdentity
Mailbox identity to configure.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -StartTime
Start time for the automatic reply.

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EndTime
End time for the automatic reply.

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -InternalMessage
Internal auto-reply message.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExternalMessage
External auto-reply message.
If omitted or blank, the internal message will also be used externally.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExternalAudience
Audience for the external message.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: All
Accept pipeline input: False
Accept wildcard characters: False
```

### -AdminUser
Administrative account used to connect.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UseWebLogin
Use web login for authentication.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -TranscriptPath
{{ Fill TranscriptPath Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
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
