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
            if ($PSBoundParameters.ContainsKey('ForEach')) { & $ScriptBlock $case } else { & $ScriptBlock }
        } catch {
            $err = $_
            $line = $err.InvocationInfo.ScriptLineNumber
            $msg = $err.Exception.Message
            throw "Test failed in ${Name}: [$msg] at line $line"
        }
    }
}

function Initialize-TestDrive {
    BeforeEach {
        if (Get-PSDrive -Name TestDrive -ErrorAction SilentlyContinue) {
            Remove-PSDrive -Name TestDrive -Force
        }
        New-PSDrive -Name TestDrive -PSProvider FileSystem -Root $TestRoot | Out-Null
    }

    AfterEach {
        if (Get-PSDrive -Name TestDrive -ErrorAction SilentlyContinue) {
            Remove-PSDrive -Name TestDrive -Force
        }
    }
}

function With-TestEnvironmentVariable {
    param(
        [Parameter(Mandatory)][string]$Name,
        [string]$Value,
        [Parameter(Mandatory)][scriptblock]$ScriptBlock
    )

    $existing = Get-Item "env:$Name" -ErrorAction SilentlyContinue
    try {
        if ($PSBoundParameters.ContainsKey('Value')) {
            Set-Item -Path "env:$Name" -Value $Value
        } else {
            Remove-Item "env:$Name" -ErrorAction SilentlyContinue
        }
        & $ScriptBlock
    } finally {
        if ($null -ne $existing) {
            Set-Item -Path "env:$Name" -Value $existing.Value
        } else {
            Remove-Item "env:$Name" -ErrorAction SilentlyContinue
        }
    }
}

