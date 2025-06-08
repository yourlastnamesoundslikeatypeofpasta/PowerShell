---
external help file: ChaosTools-help.xml
Module Name: ChaosTools
online version:
schema: 2.0.0
---

# Invoke-ChaosTest

## SYNOPSIS
Runs a script block with randomized delays and failures.

## SYNTAX

```powershell
Invoke-ChaosTest -ScriptBlock <scriptblock> [-FailureRate <double>] [-MaxDelaySeconds <int>] [<CommonParameters>]
```

## DESCRIPTION
`Invoke-ChaosTest` waits up to `MaxDelaySeconds` seconds and then randomly throws
an exception based on `FailureRate` before running the provided script block.
This helps verify that your automation gracefully handles transient errors and
slower responses.

If the `CHAOSTOOLS_ENABLED` environment variable is set to `0` or `False`, chaos
injection is skipped and the script block runs normally. Other modules such as
**ServiceDeskTools** honor the `ST_CHAOS_MODE` environment variable and call
`Invoke-ChaosTest` internally when it is set to `1`.

## EXAMPLES

### Example 1
```powershell
Invoke-ChaosTest -ScriptBlock { Get-Service } -FailureRate 0.2
```
Randomly fails twenty percent of the time after a short delay.

### Example 2
```powershell
$sb = { Invoke-RestMethod -Uri $Uri }
Invoke-ChaosTest -ScriptBlock $sb -FailureRate 0.5 -MaxDelaySeconds 10
```
Pauses up to ten seconds before running and fails half the time.

## PARAMETERS

### -ScriptBlock
Commands to invoke.

### -FailureRate
Probability from `0` to `1` that a failure is injected. Defaults to `0.3`.

### -MaxDelaySeconds
Maximum random delay before execution. Defaults to `5`.

### CommonParameters
This cmdlet supports the common parameters. For more information, see
[about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS
None.

## OUTPUTS
Any output from the script block.

## NOTES
Set `ST_CHAOS_MODE=1` to automatically enable chaos testing in other modules
that support it.

## RELATED LINKS
