. $PSScriptRoot/TestHelpers.ps1

Describe 'Sign-RepositoryFiles script' {
    Initialize-TestDrive
    BeforeAll {
        Import-Module $PSScriptRoot/../src/Logging/Logging.psd1 -Force
    }

    Safe-It 'logs an error when CertificatePath is missing' {
        Mock Write-STStatus {}
        Mock Set-AuthenticodeSignature {}
        Remove-Item env:ST_SIGN_CERT_PATH -ErrorAction SilentlyContinue
        & $PSScriptRoot/../scripts/Sign-RepositoryFiles.ps1
        Assert-MockCalled Write-STStatus -ParameterFilter { $Message -eq 'Code signing certificate path not specified.' -and $Level -eq 'ERROR' } -Times 1
        Assert-MockCalled Set-AuthenticodeSignature -Times 0
    }

    Safe-It 'signs files in src when certificate provided' {
        Mock Write-STStatus {}
        Mock Set-AuthenticodeSignature {}
        Mock Get-PfxCertificate { 'cert' }
        $certPath = Join-Path $TestDrive 'dummy.pfx'
        Set-Content -Path $certPath -Value 'dummy'
        $repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
        $target = Join-Path $repoRoot 'src/Logging/Logging.psm1'
        try {
            & $PSScriptRoot/../scripts/Sign-RepositoryFiles.ps1 -CertificatePath $certPath
            Assert-MockCalled Set-AuthenticodeSignature -ParameterFilter { $FilePath -eq $target } -Times 1
        } finally {
            Remove-Item $certPath -ErrorAction SilentlyContinue
        }
    }
}
