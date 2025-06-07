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

function Write-STDebug {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Message
    )
    if ($env:ST_DEBUG -eq '1') {
        Write-Host "[DEBUG] $Message" -ForegroundColor DarkGray
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

Export-ModuleMember -Function 'Assert-ParameterNotNull','New-STErrorObject','Write-STDebug','Test-IsElevated'

function Show-STCoreBanner {
    Write-Host 'STCore module loaded' -ForegroundColor DarkGray
}

Show-STCoreBanner
