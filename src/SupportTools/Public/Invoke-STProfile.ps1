function Invoke-STProfile {
    <#
    .SYNOPSIS
        Executes a saved SupportTools profile.
    .DESCRIPTION
        Loads a profile created by New-STProfile and invokes the stored command
        with its saved parameters.
    .PARAMETER TaskCategory
        Category under which the profile was saved.
    .PARAMETER Name
        Name of the profile to execute.
    .PARAMETER PassThru
        Return the command output.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$TaskCategory,
        [Parameter(Mandatory)]
        [string]$Name,
        [switch]$PassThru
    )

    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $result = 'Success'
    try {
        $root = if ($env:ST_PROFILE_PATH) { $env:ST_PROFILE_PATH } else {
            $home = if ($env:USERPROFILE) { $env:USERPROFILE } else { $env:HOME }
            Join-Path $home 'SupportToolsProfiles'
        }
        $path = Join-Path (Join-Path $root $TaskCategory) ($Name + '.json')
        if (-not (Test-Path $path)) { throw "Profile not found: $path" }
        $data = Get-Content $path -Raw | ConvertFrom-Json
        $command = $data.Command
        $params = @{}
        if ($data.Parameters) {
            foreach ($p in $data.Parameters.PSObject.Properties) {
                $params[$p.Name] = $p.Value
            }
        }
        Write-STLog -Message "Invoking profile $Name" -Structured -Metadata @{category=$TaskCategory; command=$command}
        Write-STStatus "Running $command using profile '$Name'" -Level INFO
        $out = & $command @params
        if ($PassThru) { return $out }
    }
    catch {
        $result = 'Failure'
        Write-STStatus "Profile execution failed: $_" -Level ERROR
        Write-STLog -Message "Profile $($Name) failed: $_" -Level ERROR -Structured -Metadata @{category=$TaskCategory}
        throw
    }
    finally {
        $sw.Stop()
        Write-STTelemetryEvent -ScriptName 'Invoke-STProfile' -Result $result -Duration $sw.Elapsed
    }
}
