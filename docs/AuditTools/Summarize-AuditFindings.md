---
external help file: AuditTools-help.xml
Module Name: AuditTools
online version:
schema: 2.0.0
---

# Summarize-AuditFindings

## SYNOPSIS
Creates a plain-language summary of audit findings using an OpenAI-compatible endpoint.

## SYNTAX
```
Summarize-AuditFindings [-InputObject] <Object> [-EndpointUri <String>] [-ApiKey <String>] [-Model <String>] [-SystemMessage <String>] [-Template <String>] [-Format <String>] [-OutputPath <String>] [<CommonParameters>]
```

## DESCRIPTION
Accepts structured audit results as objects or JSON strings. The data is inserted into a prompt template and sent to the specified API endpoint. The response text is returned or optionally written to a file in Markdown or HTML format.

## PARAMETERS
### -InputObject
Audit object or JSON to summarize. Accepts pipeline input.

### -EndpointUri
Target API endpoint. Uses `$env:ST_OPENAI_ENDPOINT` if not specified.

### -ApiKey
Authentication key. Uses `$env:ST_OPENAI_KEY` if not specified.

### -Model
Model name to request. Defaults to `gpt-3.5-turbo`.

### -SystemMessage
System role description for the assistant.

### -Template
Prompt template containing the `{data}` placeholder.

### -Format
Output format: `Text`, `Markdown` or `Html`.

### -OutputPath
Optional path to save the generated summary.

## EXAMPLES
### Example 1
```powershell
Get-AuditReport | Summarize-AuditFindings -EndpointUri 'https://api.contoso.com/openai' -ApiKey $key -Format Markdown -OutputPath summary.md
```

### Example 2
```powershell
Summarize-AuditFindings -InputObject (Get-Content audit.json) -Format Html -OutputPath report.html
```

## INPUTS
Objects

## OUTPUTS
String

## NOTES

## RELATED LINKS

