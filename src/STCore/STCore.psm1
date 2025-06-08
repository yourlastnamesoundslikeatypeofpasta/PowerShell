function Assert-ParameterNotNull {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [object]$Value,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Name
    )
    if ($null -eq $Value -or ($Value -is [string] -and $Value.Trim() -eq '')) {
        throw "Parameter '$Name' cannot be null or empty."
    }
}

function New-STErrorObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Message,
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$Category = 'General'
    )
    [pscustomobject]@{
        TimeStamp = (Get-Date).ToString('o')
        Category  = $Category
        Message   = $Message
    }
}

function New-STErrorRecord {
    <#
    .SYNOPSIS
        Creates a standardized ErrorRecord.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Message,
        [Parameter()]
        [System.Exception]$Exception = ([System.Exception]::new($Message)),
        [Parameter()]
        [System.Management.Automation.ErrorCategory]$Category = [System.Management.Automation.ErrorCategory]::NotSpecified
    )
    $err = [System.Management.Automation.ErrorRecord]::new($Exception, 'STError', $Category, $null)
    $err.ErrorDetails = [System.Management.Automation.ErrorDetails]::new($Message)
    return $err
}

function Write-STDebug {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Message
    )
    if ($env:ST_DEBUG -eq '1') {
        Write-STStatus "[DEBUG] $Message" -Level SUB
        $structured = $env:ST_LOG_STRUCTURED -eq '1'
        Write-STLog "[DEBUG] $Message" -Level INFO -Structured:$structured
    }
}

function Test-IsElevated {
    [CmdletBinding()]
    param()
    if ($IsWindows) {
        $id = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = New-Object Security.Principal.WindowsPrincipal($id)
        return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    } else {
        try { return ((id -u) -eq 0) } catch { return $false }
    }
}

function Get-STConfig {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Path
    )

    if (-not (Test-Path $Path)) { return @{} }

    try {
        $ext = [IO.Path]::GetExtension($Path).ToLower()
        switch ($ext) {
            '.json' { return Get-Content $Path | ConvertFrom-Json }
            '.psd1' { return Import-PowerShellDataFile $Path }
            default { throw "Unsupported config type: $ext" }
        }
    } catch {
        Write-STDebug "Failed to read config $Path: $_"
        return @{}
    }
}

Export-ModuleMember -Function 'Assert-ParameterNotNull','New-STErrorObject','New-STErrorRecord','Write-STDebug','Test-IsElevated','Get-STConfig'

function Show-STCoreBanner {
    <#
    .SYNOPSIS
        Returns STCore module metadata for banner display.
    #>
    [CmdletBinding()]
    param()
    $manifestPath = Join-Path $PSScriptRoot 'STCore.psd1'
    [pscustomobject]@{
        Module  = 'STCore'
        Version = (Import-PowerShellDataFile $manifestPath).ModuleVersion
    }
}
