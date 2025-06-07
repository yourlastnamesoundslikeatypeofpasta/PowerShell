---
external help file: ChaosTools-help.xml
Module Name: ChaosTools
online version:
schema: 2.0.0
---

# Invoke-ChaosTest

## SYNOPSIS
Run randomized delays and failures to test error handling.

## SYNTAX
Invoke-ChaosTest [[-Iterations] <Int32>] [[-MaxDelaySeconds] <Int32>] [[-FailureRate] <Int32>] [-ChaosMode] [<CommonParameters>]

## DESCRIPTION
`Invoke-ChaosTest` introduces random waits and optional failures. Use it during development to validate retry logic and monitoring alerts. Pass `-ChaosMode` or set the `ST_CHAOS_MODE` environment variable to enable error injection.

## PARAMETERS
### -Iterations
Number of loops to perform. Default is `5`.
### -MaxDelaySeconds
Upper bound on the delay between iterations. Default is `5` seconds.
### -FailureRate
Percentage chance that an iteration throws when chaos mode is enabled. Default is `20`.
### -ChaosMode
Switch to force chaos mode regardless of `ST_CHAOS_MODE`.

## EXAMPLES
### Example 1
```powershell
Invoke-ChaosTest -Iterations 3 -MaxDelaySeconds 2 -FailureRate 10 -ChaosMode
```
Runs three cycles with up to two seconds delay and a 10% chance to throw an error each loop.

## RELATED LINKS
[docs/ChaosTools.md](../ChaosTools.md)
