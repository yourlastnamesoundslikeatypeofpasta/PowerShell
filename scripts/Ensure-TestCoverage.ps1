# Ensure every public function has a corresponding Pester test reference

$publicDir = Join-Path $PSScriptRoot '..' 'src/SupportTools/Public'
$testDir = Join-Path $PSScriptRoot '..' 'tests'
$publicFunctions = Get-ChildItem -Path $publicDir -Filter '*.ps1' | ForEach-Object { $_.BaseName }
$missing = @()
foreach ($func in $publicFunctions) {
    $pattern = "\b$func\b"
    $found = Select-String -Path (Join-Path $testDir '*.ps1') -Pattern $pattern -SimpleMatch -CaseSensitive -Quiet
    if (-not $found) {
        Write-Error "No tests found referencing function '$func'"
        $missing += $func
    }
}
if ($missing.Count -gt 0) {
    exit 1
}
