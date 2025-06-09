function Connect-STPlatform {
    <#
    .SYNOPSIS
        Initializes required modules and service connections.
    .DESCRIPTION
        Depending on the selected Mode, imports the relevant modules and
        connects to Microsoft Graph, Active Directory and Exchange.
    .PARAMETER Mode
        Environment type: Cloud, Hybrid or OnPrem.
    .PARAMETER InstallMissing
        Install any missing modules automatically when specified.
    .PARAMETER Vault
        Secret vault name to pull credentials from when environment
        variables are missing.
    .EXAMPLE
        Connect-STPlatform -Mode Cloud
    .EXAMPLE
        Connect-STPlatform -Mode Hybrid -InstallMissing
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory)][ValidateSet('Cloud','Hybrid','OnPrem')][string]$Mode,
        [switch]$InstallMissing,
        [string]$Vault,
        [switch]$ChaosMode
    )

    if (-not $ChaosMode) { $ChaosMode = [bool]$env:ST_CHAOS_MODE }

    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $result = 'Success'
    try {
        Write-STStatus "Initializing platform for $Mode" -Level INFO -Log
        if ($ChaosMode) {
            Invoke-STRequest -Method 'GET' -Uri 'https://example.com' -ChaosMode -ErrorAction Stop | Out-Null
        }

        $requiredVars = 'SPTOOLS_CLIENT_ID','SPTOOLS_TENANT_ID','SPTOOLS_CERT_PATH','SD_API_TOKEN','SD_BASE_URI'
        foreach ($name in $requiredVars) {
            if (-not $env:$name) {
                $getParams = @{ Name = $name; AsPlainText = $true; ErrorAction = 'SilentlyContinue' }
                if ($PSBoundParameters.ContainsKey('Vault')) { $getParams.Vault = $Vault }
                $val = Get-Secret @getParams
                if ($val) {
                    $env:$name = $val
                    Write-STStatus "Loaded $name from vault" -Level SUB -Log
                } else {
                    Write-STStatus "$name not found in vault" -Level WARN -Log
                }
            }
        }
        $modules = switch ($Mode) {
            'Cloud'  { @('Microsoft.Graph','ExchangeOnlineManagement') }
            'Hybrid' { @('Microsoft.Graph','ExchangeOnlineManagement','ActiveDirectory') }
            'OnPrem' { @('ActiveDirectory','ExchangePowerShell') }
        }
        $connectionResults = @{}
        foreach ($m in $modules) {
            if (-not (Get-Module -ListAvailable -Name $m)) {
                if ($InstallMissing) {
                    Write-STStatus "Installing $m" -Level SUB -Log
                    Install-Module -Name $m -Scope CurrentUser -Force -ErrorAction Stop
                } else {
                    Write-STStatus "$m module missing." -Level WARN -Log
                }
            }
            Import-Module $m -Force -ErrorAction SilentlyContinue
        }

        switch ($Mode) {
            'Cloud' {
                try {
                    Connect-MgGraph -Scopes 'User.Read.All','Group.ReadWrite.All' -NoWelcome
                    $connectionResults.Graph = 'Success'
                } catch {
                    $connectionResults.Graph = 'Failure'
                    throw
                }
                try {
                    Connect-ExchangeOnline -ErrorAction Stop
                    $connectionResults.ExchangeOnline = 'Success'
                } catch {
                    $connectionResults.ExchangeOnline = 'Failure'
                    throw
                }
            }
            'Hybrid' {
                try {
                    Connect-MgGraph -Scopes 'User.Read.All','Group.ReadWrite.All' -NoWelcome
                    $connectionResults.Graph = 'Success'
                } catch {
                    $connectionResults.Graph = 'Failure'
                    throw
                }
                try {
                    Connect-ExchangeOnline -ErrorAction Stop
                    $connectionResults.ExchangeOnline = 'Success'
                } catch {
                    $connectionResults.ExchangeOnline = 'Failure'
                    throw
                }
            }
            'OnPrem' {
                if (Get-Command Connect-ExchangeServer -ErrorAction SilentlyContinue) {
                    try {
                        Connect-ExchangeServer -Auto
                        $connectionResults.ExchangeOnPrem = 'Success'
                    } catch {
                        $connectionResults.ExchangeOnPrem = 'Failure'
                        throw
                    }
                }
            }
        }

        Write-STStatus -Message 'Connections initialized.' -Level SUCCESS -Log
    } catch {
        $result = 'Failure'
        Write-STFailure "Connect-STPlatform failed: $_"
        throw
    } finally {
        $sw.Stop()
        Send-STMetric -MetricName 'Connect-STPlatform' -Category 'Setup' -Value $sw.Elapsed.TotalSeconds -Details @{ Mode = $Mode; Result = $result; Modules = $modules; Connections = $connectionResults }
    }
}
