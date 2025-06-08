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
    .EXAMPLE
        Connect-STPlatform -Mode Cloud
    .EXAMPLE
        Connect-STPlatform -Mode Hybrid -InstallMissing
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][ValidateSet('Cloud','Hybrid','OnPrem')][string]$Mode,
        [switch]$InstallMissing
    )

    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $result = 'Success'
    try {
        Write-STStatus "Initializing platform for $Mode" -Level INFO -Log
        $modules = switch ($Mode) {
            'Cloud'  { @('Microsoft.Graph','ExchangeOnlineManagement') }
            'Hybrid' { @('Microsoft.Graph','ExchangeOnlineManagement','ActiveDirectory') }
            'OnPrem' { @('ActiveDirectory','ExchangePowerShell') }
        }
        foreach ($m in $modules) {
            if (-not (Get-Module -ListAvailable -Name $m)) {
                if ($InstallMissing) {
                    Write-STStatus "Installing $m" -Level SUB -Log
                    Install-Module -Name $m -Scope CurrentUser -Force -ErrorAction Stop
                } else {
                    Write-STStatus "$m module missing." -Level WARN -Log
                }
            }
            Import-Module $m -ErrorAction SilentlyContinue
        }

        switch ($Mode) {
            'Cloud' {
                Connect-MgGraph -Scopes 'User.Read.All','Group.ReadWrite.All' -NoWelcome
                Connect-ExchangeOnline -ErrorAction Stop
            }
            'Hybrid' {
                Connect-MgGraph -Scopes 'User.Read.All','Group.ReadWrite.All' -NoWelcome
                Connect-ExchangeOnline -ErrorAction Stop
            }
            'OnPrem' {
                if (Get-Command Connect-ExchangeServer -ErrorAction SilentlyContinue) {
                    Connect-ExchangeServer -Auto
                }
            }
        }

        Write-STStatus 'Connections initialized.' -Level SUCCESS -Log
    } catch {
        $result = 'Failure'
        Write-STStatus "Connect-STPlatform failed: $_" -Level ERROR -Log
        Write-STLog -Message "Connect-STPlatform failed: $_" -Level ERROR
        throw
    } finally {
        $sw.Stop()
        Send-STMetric -MetricName 'Connect-STPlatform' -Category 'Setup' -Value $sw.Elapsed.TotalSeconds -Details @{ Mode = $Mode; Result = $result }
    }
}
