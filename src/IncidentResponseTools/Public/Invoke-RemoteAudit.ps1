function Invoke-RemoteAudit {
    <#
    .SYNOPSIS
        Collects common system information from remote computers.
    .DESCRIPTION
        Uses PowerShell remoting to run Get-CommonSystemInfo on one or more
        target computers. The command returns an object for each computer
        containing the collected information or the error encountered.
    .PARAMETER ComputerName
        One or more computer names to audit remotely.
    .PARAMETER Credential
        Credential to use for the remote session.
    .PARAMETER UseSSL
        Use HTTPS/SSL for the remoting session.
    .PARAMETER Port
        Alternate port number for the remote session.
    .OUTPUTS
        PSCustomObject with ComputerName, Success, and either Info or Error
        properties describing the result for each computer.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]]$ComputerName,
        [Parameter()]
        [System.Management.Automation.PSCredential]$Credential,
        [switch]$UseSSL,
        [ValidateRange(1, 65535)]
        [int]$Port = 5985
    )
    process {
        foreach ($comp in $ComputerName) {
            $invokeParams = @{ ComputerName = $comp }
            if ($PSBoundParameters.ContainsKey('Credential')) { $invokeParams.Credential = $Credential }
            if ($UseSSL) { $invokeParams.UseSSL = $true }
            if ($PSBoundParameters.ContainsKey('Port')) { $invokeParams.Port = $Port }
            try {
                $info = Invoke-Command @invokeParams -ScriptBlock { Get-CommonSystemInfo }
                [pscustomobject]@{
                    ComputerName = $comp
                    Info         = $info
                    Success      = $true
                }
            }
            catch {
                [pscustomobject]@{
                    ComputerName = $comp
                    Error        = $_.Exception.Message
                    Success      = $false
                }
            }
        }
    }
}
