---
external help file: SupportTools-help.xml
Module Name: IncidentResponseTools
online version:
schema: 2.0.0
---

# Invoke-IncidentResponse

## SYNOPSIS
Collect incident response data and optionally submit a Service Desk ticket.

## SYNTAX
```
Invoke-IncidentResponse [[-Arguments] <Object[]>] [[-TranscriptPath] <String>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
Wraps the `Invoke-IncidentResponse.ps1` script. The command gathers recent event logs,
process details, network connections and other information into a timestamped folder.
If unsigned processes are found running from temporary directories a ticket is created
via `Submit-Ticket` in the ServiceDeskTools module.
