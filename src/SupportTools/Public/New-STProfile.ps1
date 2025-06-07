function New-STProfile {
    <#
    .SYNOPSIS
        Saves a named parameter profile for later use.
    .DESCRIPTION
        Stores the provided command name and parameters into a JSON file so the
        profile can be invoked at a later time with Invoke-STProfile.
    .PARAMETER TaskCategory
        Logical grouping for the profile (e.g. Audit, Performance).
    .PARAMETER Name
        Name of the profile to create.
    .PARAMETER Command
        The cmdlet to run when this profile is invoked.
    .PARAMETER Parameters
        Hashtable of parameters for the cmdlet.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$TaskCategory,
        [Parameter(Mandatory)]
        [string]$Name,
        [Parameter(Mandatory)]
        [string]$Command,
        [hashtable]$Parameters = @{}
    )

    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $result = 'Success'
    try {
        $root = if ($env:ST_PROFILE_PATH) { $env:ST_PROFILE_PATH } else {
            $home = if ($env:USERPROFILE) { $env:USERPROFILE } else { $env:HOME }
            Join-Path $home 'SupportToolsProfiles'
        }
        $categoryDir = Join-Path $root $TaskCategory
        if (-not (Test-Path $categoryDir)) {
            New-Item -Path $categoryDir -ItemType Directory -Force | Out-Null
        }
        $path = Join-Path $categoryDir ($Name + '.json')
        $obj = [pscustomobject]@{
            Command    = $Command
            Parameters = $Parameters
        }
        $obj | ConvertTo-Json -Depth 5 | Out-File -FilePath $path -Encoding utf8
        Write-STStatus "Profile '$Name' saved" -Level SUCCESS
        Write-STLog -Message "Saved profile $Name" -Structured -Metadata @{category=$TaskCategory; command=$Command}
    }
    catch {
        $result = 'Failure'
        Write-STStatus "Failed to save profile: $_" -Level ERROR
        Write-STLog -Message "Failed to save profile $($Name): $_" -Level ERROR -Structured -Metadata @{category=$TaskCategory; command=$Command}
        throw
    }
    finally {
        $sw.Stop()
        Write-STTelemetryEvent -ScriptName 'New-STProfile' -Result $result -Duration $sw.Elapsed
    }
}
