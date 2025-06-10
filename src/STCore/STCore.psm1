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
        Write-STLog "[DEBUG] $Message" -Level INFO
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
            '.json' { return Get-Content $Path | ConvertFrom-Json -AsHashtable }
            '.psd1' { return Import-PowerShellDataFile $Path }
            default { throw "Unsupported config type: $ext" }
        }
    } catch {
        Write-STDebug "Failed to read config ${Path}: $_"
        return @{}
    }
}

function Get-STConfigValue {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][hashtable]$Config,
        [Parameter(Mandatory)][string]$Key,
        $Default = $null
    )
    if (-not $Config) { return $Default }
    if ($Config.ContainsKey($Key) -and $Config[$Key]) { return $Config[$Key] }
    return $Default
}

function Invoke-STRequest {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Method,
        [Parameter(Mandatory)][string]$Uri,
        [hashtable]$Headers,
        [object]$Body,
        [string]$ContentType = 'application/json',
        [switch]$ChaosMode
    )

    Assert-ParameterNotNull $Method 'Method'
    Assert-ParameterNotNull $Uri 'Uri'

    if (-not $ChaosMode) { $ChaosMode = [bool]$env:ST_CHAOS_MODE }
    if ($ChaosMode) {
        $delay = Get-Random -Minimum 500 -Maximum 1500
        Write-STLog -Message "CHAOS MODE delay $delay ms"
        Start-Sleep -Milliseconds $delay
        $roll = Get-Random -Minimum 1 -Maximum 100
        if ($roll -le 10) { throw 'ChaosMode: simulated throttling (429 Too Many Requests)' }
        elseif ($roll -le 20) { throw 'ChaosMode: simulated server error (500 Internal Server Error)' }
    }

    Write-STLog -Message "STRequest $Method $Uri"
    Write-Verbose "Invoking $Method $Uri"

    $json = if ($PSBoundParameters.ContainsKey('Body')) {
        if ($ContentType -match 'json') { $Body | ConvertTo-Json -Depth 10 } else { $Body }
    } else { $null }

    $maxRetries = 3
    $attempt = 1
    while ($true) {
        try {
            if ($json) {
                $response = Invoke-RestMethod -Method $Method -Uri $Uri -Headers $Headers -Body $json -ContentType $ContentType -ErrorAction Stop
            } else {
                $response = Invoke-RestMethod -Method $Method -Uri $Uri -Headers $Headers -ErrorAction Stop
            }
            Write-STLog -Message "SUCCESS $Method $Uri"
            return $response
        } catch [System.Net.WebException],[Microsoft.PowerShell.Commands.HttpResponseException] {
            $status = $_.Exception.Response.StatusCode.value__
            $msg    = $_.Exception.Message
            Write-STLog -Message "HTTP $status $msg" -Level 'ERROR'
            if ($status -eq 429 -or ($status -ge 500 -and $status -lt 600)) {
                if ($attempt -lt $maxRetries) {
                    $retryAfter = $_.Exception.Response.Headers['Retry-After']
                    if ($retryAfter) { $delay = [int]$retryAfter } else { $delay = [math]::Pow(2, $attempt) }
                    Write-STLog -Message "Retry $attempt in $delay sec" -Level WARN
                    Write-Verbose "Retrying in $delay seconds"
                    Start-Sleep -Seconds $delay
                    $attempt++
                    continue
                }
            }
            $errorObj = New-STErrorObject -Message "HTTP $status $msg" -Category 'HTTP'
            throw $errorObj
        } catch {
            Write-STLog -Message "ERROR $Method $Uri :: $_" -Level 'ERROR'
            throw
        }
    }
}

function Get-STSecret {
    <#
    .SYNOPSIS
        Retrieves an environment variable or secret from a vault.
    .DESCRIPTION
        Returns the environment variable value when present. If missing,
        calls Get-Secret with -AsPlainText to load the value optionally from
        the specified vault. When retrieved from a vault the value is written
        back to the environment and a status message is logged.
    .PARAMETER Name
        Name of the environment variable and secret.
    .PARAMETER Vault
        Optional SecretManagement vault name.
    .PARAMETER Required
        Throw if the value cannot be resolved.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Name,
        [string]$Vault,
        [switch]$Required
    )

    if ($env:$Name) { return $env:$Name }

    $params = @{ Name = $Name; AsPlainText = $true; ErrorAction = 'SilentlyContinue' }
    if ($PSBoundParameters.ContainsKey('Vault')) { $params.Vault = $Vault }
    $val = Get-Secret @params

    if ($val) {
        $env:$Name = $val
        Write-STStatus "Loaded $Name from vault" -Level SUB -Log
        return $val
    }

    Write-STStatus "$Name not found in vault" -Level WARN -Log
    if ($Required) { throw "$Name environment variable must be set." }
    return $null
}

Export-ModuleMember -Function 'Assert-ParameterNotNull','New-STErrorObject','New-STErrorRecord','Write-STDebug','Test-IsElevated','Get-STConfig','Get-STConfigValue','Invoke-STRequest','Get-STSecret'

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
