# Rich Logging Standard

All SupportTools commands should log structured events in a single JSON format. Each log entry is one compact JSON object per line. The schema is inspired by W3C Common Event Format.

```json
{
  "timestamp": "2025-06-06T19:11:00Z",
  "tool": "AddUsersToGroup",
  "status": "success",
  "user": "jane.doe@company.com",
  "duration": "00:01:42",
  "details": ["User already in group", "User added"]
}
```

Use `Write-STRichLog` to emit entries in this format. Logs default to `~/SupportToolsLogs/supporttools.log` unless a custom path is provided or `ST_LOG_PATH` is set.
