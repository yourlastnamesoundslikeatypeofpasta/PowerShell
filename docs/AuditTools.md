# AuditTools Module

Provides commands for summarizing audit data using an OpenAI-compatible API. Import the module using its manifest:

```powershell
Import-Module ./src/AuditTools/AuditTools.psd1
```

## Available Commands

| Command | Description |
|---------|-------------|
| `Summarize-AuditFindings` | Send audit data to an API endpoint and generate an executive summary. |
