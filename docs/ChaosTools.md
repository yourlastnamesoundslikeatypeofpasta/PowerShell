# ChaosTools Module

Provides utilities for injecting random failures to test robustness of scripts.
Import the module manifest and run `Invoke-ChaosTest` with a script block that
executes the commands you want to exercise.

```powershell
Import-Module ./src/ChaosTools/ChaosTools.psd1
Invoke-ChaosTest -ScriptBlock { Get-ChildItem -Path . } -Scope 'Get-ChildItem'
```

The `-Scope` parameter lists the cmdlets that should be wrapped. During
test execution the wrapper randomly delays execution, throws transient
errors, or tweaks parameter values. All chaos injections are written to
the log using `Write-STLog` so failures can be traced easily.
