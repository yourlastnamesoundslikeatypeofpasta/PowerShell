function Export-ProductKey {
    <#
    .SYNOPSIS
        Retrieves the Windows product key.
    .DESCRIPTION
        Queries the SoftwareLicensingService WMI class for the original
        product key of the system and writes it to the specified path.

    .PARAMETER OutputPath
        Path to the file where the product key should be written.

    .PARAMETER TranscriptPath
        Optional path for a transcript log.

    .EXAMPLE
        Export-ProductKey -OutputPath ./productkey.txt

        Retrieves the local product key and saves it to `productkey.txt`.

    .NOTES
        Administrative privileges are required to query the licensing service.
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$OutputPath,
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$TranscriptPath
    )

    try {
        if ($TranscriptPath) { Start-Transcript -Path $TranscriptPath -Append | Out-Null }

        try {
            $key = Get-CimInstance -ClassName SoftwareLicensingService -ErrorAction Stop | Select-Object -ExpandProperty OA3xOriginalProductKey
        } catch {
            Write-Error $_.Exception.Message
            throw
        }

        if (-not $key) {
            Write-STStatus -Message 'Product key not found.' -Level WARN
            return
        }

        if (-not $PSCmdlet.ShouldProcess($OutputPath, 'Export product key')) { return }
        try {
            Set-Content -Path $OutputPath -Value $key -ErrorAction Stop
        } catch {
            Write-Error $_.Exception.Message
            throw
        }

        Write-STStatus "Product key exported to $OutputPath" -Level SUCCESS
        return [pscustomobject]@{
            ProductKey = $key
            OutputPath = $OutputPath
        }
    } finally {
        if ($TranscriptPath) { Stop-Transcript | Out-Null }
    }
}
