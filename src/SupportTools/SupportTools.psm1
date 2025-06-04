function Invoke-ScriptFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name,
        [Parameter(ValueFromRemainingArguments=$true)]
        [object[]]$Args
    )
    $path = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath '..' | Join-Path -ChildPath "scripts/$Name"
    if (-not (Test-Path $path)) { throw "Script '$Name' not found." }
    & $path @Args
}

function AddUsersToGroup {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [object[]]$Arguments
    )
    Invoke-ScriptFile -Name "AddUsersToGroup.ps1" -Args $Arguments
}

function CleanupArchive {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [object[]]$Arguments
    )
    Invoke-ScriptFile -Name "CleanupArchive.ps1" -Args $Arguments
}

function Convert-ExcelToCsv {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [object[]]$Arguments
    )
    Invoke-ScriptFile -Name "Convert-ExcelToCsv.ps1" -Args $Arguments
}

function Get-CommonSystemInfo {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [object[]]$Arguments
    )
    Invoke-ScriptFile -Name "Get-CommonSystemInfo.ps1" -Args $Arguments
}

function Get-FailedLogins {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [object[]]$Arguments
    )
    Invoke-ScriptFile -Name "Get-FailedLogins.ps1" -Args $Arguments
}

function Get-NetworkShares {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [object[]]$Arguments
    )
    Invoke-ScriptFile -Name "Get-NetworkShares.ps1" -Args $Arguments
}

function Get-UniquePermissions {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [object[]]$Arguments
    )
    Invoke-ScriptFile -Name "Get-UniquePermissions.ps1" -Args $Arguments
}

function Install-Fonts {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [object[]]$Arguments
    )
    Invoke-ScriptFile -Name "Install-Fonts.ps1" -Args $Arguments
}

function PostInstallScript {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [object[]]$Arguments
    )
    Invoke-ScriptFile -Name "PostInstallScript.ps1" -Args $Arguments
}

function ProductKey {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [object[]]$Arguments
    )
    Invoke-ScriptFile -Name "ProductKey.ps1" -Args $Arguments
}

function SS_DEPLOYMENT_TEMPLATE {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [object[]]$Arguments
    )
    Invoke-ScriptFile -Name "SS_DEPLOYMENT_TEMPLATE.ps1" -Args $Arguments
}

function Search-ReadMe {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [object[]]$Arguments
    )
    Invoke-ScriptFile -Name "Search-ReadMe.ps1" -Args $Arguments
}

function Set-ComputerIPAddress {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [object[]]$Arguments
    )
    Invoke-ScriptFile -Name "Set-ComputerIPAddress.ps1" -Args $Arguments
}

function Set-NetAdapterMetering {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [object[]]$Arguments
    )
    Invoke-ScriptFile -Name "Set-NetAdapterMetering.ps1" -Args $Arguments
}

function Set-TimeZoneEasternStandardTime {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [object[]]$Arguments
    )
    Invoke-ScriptFile -Name "Set-TimeZoneEasternStandardTime.ps1" -Args $Arguments
}

function SimpleCountdown {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [object[]]$Arguments
    )
    Invoke-ScriptFile -Name "SimpleCountdown.ps1" -Args $Arguments
}

function Update-Sysmon {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [object[]]$Arguments
    )
    Invoke-ScriptFile -Name "Update-Sysmon.ps1" -Args $Arguments
}

