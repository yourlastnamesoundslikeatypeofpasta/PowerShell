function Safe-It {
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][scriptblock]$ScriptBlock,
        [object[]]$ForEach
    )
    $itParams = @{ Name = $Name }
    if ($PSBoundParameters.ContainsKey('ForEach')) { $itParams.ForEach = $ForEach }
    It @itParams {
        param($case)
        try {
            if (Get-PSDrive -Name TestDrive -ErrorAction SilentlyContinue) {
                Remove-PSDrive -Name TestDrive -Force -ErrorAction SilentlyContinue
            }
            if ($PSBoundParameters.ContainsKey('ForEach')) { & $ScriptBlock $case } else { & $ScriptBlock }
        } catch {
            $err = $_
            $line = $err.InvocationInfo.ScriptLineNumber
            $msg = $err.Exception.Message
            throw "Test failed in ${Name}: [$msg] at line $line"
        }
    }
}

if (-not $script:TestDriveCleanupAdded) {
    AfterEach {
        if (Get-PSDrive -Name TestDrive -ErrorAction SilentlyContinue) {
            Remove-PSDrive -Name TestDrive -Force -ErrorAction SilentlyContinue
        }
    }
    $script:TestDriveCleanupAdded = $true
}
