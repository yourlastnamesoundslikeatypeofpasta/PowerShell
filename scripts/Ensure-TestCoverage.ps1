# Ensure every public function has a corresponding Pester test reference

$publicDir = Join-Path $PSScriptRoot '..' 'src/SupportTools/Public'
$testDir = Join-Path $PSScriptRoot '..' 'tests'
$publicFunctions = Get-ChildItem -Path $publicDir -Filter '*.ps1' | ForEach-Object { $_.BaseName }
$missing = [System.Collections.Generic.List[object]]::new()
foreach ($func in $publicFunctions) {
    $pattern = "\b$func\b"
    $found = Select-String -Path (Join-Path $testDir '*.ps1') -Pattern $pattern -CaseSensitive -Quiet
    if (-not $found) {
        Write-Error "No tests found referencing function '$func'"
        # Use Add() to avoid array resizing in the loop
        $missing.Add($func)
    }
}
if ($missing.Count -gt 0) {
    exit 1
}
