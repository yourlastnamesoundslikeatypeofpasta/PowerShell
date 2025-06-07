---
external help file: PerformanceTools-help.xml
Module Name: PerformanceTools
online version:
schema: 2.0.0
---

# Measure-STCommand

## SYNOPSIS
Measures execution time, CPU usage and memory change for a script block.

## SYNTAX
```powershell
Measure-STCommand [-ScriptBlock] <scriptblock> [-Quiet] [<CommonParameters>]
```

## DESCRIPTION
Runs the supplied script block and returns an object with the total duration in seconds,
processor time consumed and change in working set memory. By default it also prints
this information using the logging helpers.

## EXAMPLES
### Example 1
```powershell
PS C:\> Measure-STCommand { Get-Process pwsh }
```

Demonstrates collecting performance metrics for a command.

## PARAMETERS
### -ScriptBlock
Script block containing the commands to execute.

```yaml
Type: ScriptBlock
Parameter Sets: (All)
Aliases: sb
```

### -Quiet
Suppress status output and only return the metrics object.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
```

## INPUTS
### None

## OUTPUTS
```
System.Object
```

Object with the properties `DurationSeconds`, `CpuSeconds` and `MemoryDeltaMB`.

## NOTES
## RELATED LINKS

