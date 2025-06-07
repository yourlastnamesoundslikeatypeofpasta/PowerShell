$loggingModule = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath 'Logging/Logging.psd1'
Import-Module $loggingModule -ErrorAction SilentlyContinue
$telemetryModule = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath 'Telemetry/Telemetry.psd1'
Import-Module $telemetryModule -ErrorAction SilentlyContinue

function Invoke-ChaosTest {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [scriptblock]$ScriptBlock,
        [string[]]$Scope = @()
    )

    $wrapped = @()
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    try {
        foreach ($cmd in $Scope) {
            $command = Get-Command $cmd -ErrorAction SilentlyContinue
            if (-not $command) {
                Write-STStatus "[Chaos] Command $cmd not found" -Level WARN -Log
                continue
            }
            $qualified = if ($command.Source) { "$($command.Source)\$($command.Name)" } else { $command.Name }
            $code = @"
param([object[]]`$Args)
Write-STLog -Message '[Chaos] Intercepted $cmd' -Structured
`$rand = Get-Random -Minimum 1 -Maximum 101
if (`$rand -le 30) {
    `$delay = Get-Random -Minimum 1 -Maximum 3
    Write-STStatus "[Chaos] Delay $cmd by $delay sec" -Level WARN -Log
    Start-Sleep -Seconds `$delay
} elseif (`$rand -le 60) {
    Write-STStatus "[Chaos] Throwing transient error for $cmd" -Level ERROR -Log
    throw 'ChaosTest simulated transient error'
} elseif (`$rand -le 90) {
    Write-STStatus "[Chaos] Modifying parameters for $cmd" -Level WARN -Log
    `$Args = `$Args | ForEach-Object {
        if (`$_ -is [int]) { `$_ + 1 }
        elseif (`$_ -is [double]) { `$_ + 1 }
        elseif (`$_ -is [string]) { "`$_-typo" }
        else { `$_ }
    }
}
& $qualified @Args
"@
            Set-Item -Path "function:$cmd" -Value ([scriptblock]::Create($code)) -Force
            $wrapped += $cmd
        }

        & $ScriptBlock
        $sw.Stop()
        Write-STTelemetryEvent -ScriptName 'Invoke-ChaosTest' -Result 'Success' -Duration $sw.Elapsed
    } catch {
        $sw.Stop()
        Write-STTelemetryEvent -ScriptName 'Invoke-ChaosTest' -Result 'Failure' -Duration $sw.Elapsed
        throw
    } finally {
        foreach ($cmd in $wrapped) {
            Remove-Item -Path "function:$cmd" -Force -ErrorAction SilentlyContinue
        }
    }
}

Export-ModuleMember -Function 'Invoke-ChaosTest'

function Show-ChaosToolsBanner {
    Write-STDivider 'CHAOSTOOLS MODULE LOADED' -Style heavy
    Write-STStatus "Run 'Get-Command -Module ChaosTools' to view available tools." -Level SUB
    Write-STLog -Message 'ChaosTools module loaded'
}

Show-ChaosToolsBanner
