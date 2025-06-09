# ChaosTools Module

ChaosTools is currently in **Beta**.

Provides helpers for chaos testing and fault injection.
Commands follow the logging conventions described in
[ModuleStyleGuide.md](ModuleStyleGuide.md).
Import the module with its manifest:

```powershell
Import-Module ./src/ChaosTools/ChaosTools.psd1
```

## Available Commands

| Command | Description | Example |
|---------|-------------|---------|
| `Invoke-ChaosTest` | Randomly delay or fail execution of a script block | `Invoke-ChaosTest -ScriptBlock { Get-Service } -FailureRate 0.2` |

Chaos behavior can also be triggered in other modules. Set the `ST_CHAOS_MODE`
environment variable to `1` (or use the `-ChaosMode` switch where available) to
have commands automatically wrap API calls with `Invoke-ChaosTest`. Set
`CHAOSTOOLS_ENABLED` to `0` or `False` to bypass delays and failures when calling
`Invoke-ChaosTest` directly.

```powershell
$env:ST_CHAOS_MODE = '1'       # enable automatic chaos in other modules
$env:CHAOSTOOLS_ENABLED = '0'  # bypass chaos in Invoke-ChaosTest
```

`ST_CHAOS_MODE` instructs modules to inject chaos automatically. Setting
`CHAOSTOOLS_ENABLED` to `0` disables chaos effects when `Invoke-ChaosTest` is run explicitly.

See [ChaosTools/Invoke-ChaosTest.md](ChaosTools/Invoke-ChaosTest.md) for full
command documentation.

Use these tools to validate that your automation gracefully handles transient failures.

## Example

Proper error handling is required when chaos is enabled. Wrap calls to `Invoke-ChaosTest` in a `try`/`catch` block and log failures:

```powershell
try {
    Invoke-ChaosTest -ScriptBlock { Invoke-RestMethod $uri }
} catch {
    Write-STStatus -Message $_ -Level ERROR
}
```

