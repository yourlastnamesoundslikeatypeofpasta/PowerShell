# Testing Guidelines

This repository uses Pester for unit tests. New tests should wrap assertions in
`Safe-It` instead of `It` to ensure failures are reported with clear context and
do not break unrelated cases.

```powershell
. $PSScriptRoot/../TestHelpers.ps1
Safe-It 'does something' {
    # test code
}
```

`Safe-It` catches any exception thrown within the block and rethrows a simplified
message that includes the failing test name and the error line number. Use
`TestDrive:` for temporary files and mock external calls so tests do not depend
on the local environment.
