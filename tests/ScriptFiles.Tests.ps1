Describe 'Standalone Scripts' {
    It 'generates maintenance task XML without registering' {
        $tempDir = Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName())
        New-Item -ItemType Directory -Path $tempDir | Out-Null
        Push-Location $tempDir
        try {
            & $PSScriptRoot/../scripts/Setup-ScheduledMaintenance.ps1
            Test-Path 'WeeklyCleanupTask.xml' | Should -Be $true
            Test-Path 'GroupMaintenanceTask.xml' | Should -Be $true
            Test-Path 'PermissionAuditTask.xml' | Should -Be $true
        } finally {
            Pop-Location
            Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    It 'builds a function dependency graph' {
        $result = & $PSScriptRoot/../scripts/Get-FunctionDependencyGraph.ps1 -Path $PSScriptRoot/../scripts/AddUsersToGroup.ps1 -Format Graphviz
        $result | Should -Match 'digraph'
        $result | Should -Match 'Start-Main'
    }
}
