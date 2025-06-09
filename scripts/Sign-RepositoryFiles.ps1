<#$
.SYNOPSIS
    Signs all PowerShell files in the repository.
.DESCRIPTION
    Iterates through the `src` and `scripts` folders and signs every
    `.ps1`, `.psm1` and `.psd1` file using Set-AuthenticodeSignature.
.PARAMETER CertificatePath
    Path to the code-signing certificate (PFX). If not provided,
    the script uses the ST_SIGN_CERT_PATH environment variable.
.EXAMPLE
    $env:ST_SIGN_CERT_PATH = 'C:\certs\internal.pfx'
    ./Sign-RepositoryFiles.ps1
#>
param(
    [string]$CertificatePath = $env:ST_SIGN_CERT_PATH
)

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
Import-Module (Join-Path $repoRoot 'src/Logging/Logging.psd1') -ErrorAction SilentlyContinue

Show-STPrompt './scripts/Sign-RepositoryFiles.ps1'

if (-not $CertificatePath) {
    Write-STStatus 'Code signing certificate path not specified.' -Level ERROR
    return
}

if (-not (Test-Path $CertificatePath)) {
    Write-STStatus "Certificate not found at $CertificatePath" -Level ERROR
    return
}

$cert = Get-PfxCertificate -FilePath $CertificatePath

Write-STDivider 'SIGNING FILES'

$folders = @('src','scripts') | ForEach-Object { Join-Path $repoRoot $_ }
foreach ($folder in $folders) {
    Get-ChildItem -Path $folder -Recurse -Include '*.ps1','*.psm1','*.psd1' | ForEach-Object {
        Write-STStatus "Signing $($_.FullName)" -Level INFO
        try {
            Set-AuthenticodeSignature -FilePath $_.FullName -Certificate $cert | Out-Null
        } catch {
            Write-STStatus "Failed to sign $($_.FullName): $_" -Level ERROR
        }
    }
}

Write-STClosing 'Repository signing complete'
