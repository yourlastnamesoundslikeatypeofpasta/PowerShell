function Invoke-RemoteAudit {
    <#
    .SYNOPSIS
        Runs audit commands on remote computers using PowerShell remoting.
    .DESCRIPTION
        Establishes a remote session for each computer, executes the specified
        audit commands (Get-CommonSystemInfo and Get-FailedLogin by default) and
        aggregates the results locally.
    .PARAMETER ComputerName
        Target computers to audit.
    .PARAMETER AuditCommands
        Names of audit commands to run remotely.
    .PARAMETER Credential
        Optional credential used for the remote connection. If omitted and the
        default connection fails, you will be prompted for alternate
        credentials.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string[]]$ComputerName,
        [string[]]$AuditCommands = @('Get-CommonSystemInfo','Get-FailedLogin'),
        [pscredential]$Credential
    )

    begin {
        Import-Module (Join-Path $PSScriptRoot '../../Logging/Logging.psd1') -ErrorAction SilentlyContinue
        $results = @()
    }

    process {
        foreach ($name in $ComputerName) {
            $session = $null
            try {
                Write-STStatus "Connecting to $name..." -Level INFO -Log
                if ($Credential) {
                    $session = New-PSSession -ComputerName $name -Credential $Credential -ErrorAction Stop
                } else {
                    $session = New-PSSession -ComputerName $name -ErrorAction Stop
                }
            } catch {
                if (-not $Credential) {
                    Write-STStatus "Connection to $name failed. Prompting for credentials..." -Level WARN -Log
                    $cred = Get-Credential
                    try {
                        $session = New-PSSession -ComputerName $name -Credential $cred -ErrorAction Stop
                    } catch {
                        Write-STStatus "Unable to connect to ${name}: $_" -Level ERROR -Log
                        $results += [pscustomobject]@{ ComputerName = $name; Error = $_.Exception.Message }
                        continue
                    }
                } else {
                    Write-STStatus "Unable to connect to ${name}: $_" -Level ERROR -Log
                    $results += [pscustomobject]@{ ComputerName = $name; Error = $_.Exception.Message }
                    continue
                }
            }

            try {
                $sb = {
                    param($cmds)
                    Import-Module SupportTools -ErrorAction SilentlyContinue
                    $out = @{}
                    foreach ($c in $cmds) {
                        if (Get-Command -Name $c -ErrorAction SilentlyContinue) {
                            $out[$c] = & $c
                        } else {
                            $out[$c] = 'CommandNotFound'
                        }
                    }
                    return $out
                }

                $data = Invoke-Command -Session $session -ScriptBlock $sb -ArgumentList (, $AuditCommands) -ErrorAction Stop
                $results += [pscustomobject]@{ ComputerName = $name; Result = $data }
                Write-STStatus "Collected audit data from $name." -Level SUCCESS -Log
            } catch {
                Write-STStatus "Failed to run audit on ${name}: $_" -Level ERROR -Log
                $results += [pscustomobject]@{ ComputerName = $name; Error = $_.Exception.Message }
            } finally {
                if ($session) { Remove-PSSession $session }
            }
        }
    }

    end {
        return $results
    }
}
