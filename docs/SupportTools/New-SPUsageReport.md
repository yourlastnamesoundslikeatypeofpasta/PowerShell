# New-SPUsageReport

Generates library usage reports for all configured SharePoint sites and optionally creates Service Desk tickets when libraries exceed a specified item count.

```
New-SPUsageReport [-ItemThreshold <Int>] [-RequesterEmail <String>] [-CsvPath <String>] [-TranscriptPath <String>]
```

When `-RequesterEmail` is provided, libraries with an `ItemCount` greater than `-ItemThreshold` trigger a call to `New-SDTicket` for follow-up.

## OUTPUTS

Returns an object describing the wrapped script execution.

```
Script : Generate-SPUsageReport.ps1
Result : <object[]>
```
