function Export-ProductKey {
    <#
    .SYNOPSIS
        Retrieves the Windows product key.
    .DESCRIPTION
        Queries the SoftwareLicensingService WMI class for the original
        product key of the system and writes it to the specified path.
    .PARAMETER OutputPath
        Path to the file where the product key should be written.
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

        $key = (Get-CimInstance -ClassName SoftwareLicensingService | Select-Object -ExpandProperty OA3xOriginalProductKey)
        if (-not $key) {
            Write-STStatus 'Product key not found.' -Level WARN
            return
        }

        Set-Content -Path $OutputPath -Value $key
        Write-STStatus "Product key exported to $OutputPath" -Level SUCCESS
        return [pscustomobject]@{
            ProductKey = $key
            OutputPath = $OutputPath
        }
    } finally {
        if ($TranscriptPath) { Stop-Transcript | Out-Null }
    }
}
