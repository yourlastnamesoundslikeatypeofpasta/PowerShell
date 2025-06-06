# PSScriptAnalyzer workflow fails on 'OutFile' parameter

## Summary
The "PowerShell Lint" workflow fails because `Invoke-ScriptAnalyzer` doesn't recognize the `-OutFile` parameter. As a result, the job exits with code 1 and the lint results are never uploaded.

## Steps to Reproduce
1. Trigger the **PowerShell Lint** workflow (e.g., by pushing a commit that modifies a `.ps1` file).
2. Observe the workflow logs.

The command in the workflow is executed as:

```pwsh
Invoke-ScriptAnalyzer -Path . -Recurse -Severity Warning,Error -OutFile PSScriptAnalyzerResults.sarif -ReportSummary
```

## Actual Result
The step fails with the following error:

```
Invoke-ScriptAnalyzer: /home/runner/work/_temp/d2ea14ed-2bd7-483e-bfa4-586ae638546d.ps1:2
A parameter cannot be found that matches parameter name 'OutFile'.
```

## Expected Result
The command should run successfully and create `PSScriptAnalyzerResults.sarif` so the artifact can be uploaded.

## Technical Details
- The failing step is defined in `.github/workflows/psscriptanalyzer.yml` lines 18-26:
  ```yaml
  - name: Install PSScriptAnalyzer
    shell: pwsh
    run: |
      Install-Module PSScriptAnalyzer -Force -Scope CurrentUser
  - name: Run PSScriptAnalyzer
    shell: pwsh
    run: |
      Invoke-ScriptAnalyzer -Path . -Recurse -Severity Warning,Error -OutFile PSScriptAnalyzerResults.sarif -ReportSummary
  ```
- GitHub Actions runner: `ubuntu-latest`.
- The log excerpt shows `Invoke-ScriptAnalyzer` does not accept the `-OutFile` parameter, which implies that either the installed version is older than expected or the command is incorrect.

## Suggested Fix
Update the workflow to use `Invoke-ScriptAnalyzer`'s supported parameters. If the intent is to save results to a SARIF file, `Invoke-ScriptAnalyzer` can output objects which can then be converted using `ConvertTo-Sarif`. Alternatively, confirm that the latest PSScriptAnalyzer version is installed or replace `-OutFile` with `-ReportSummary` only.

