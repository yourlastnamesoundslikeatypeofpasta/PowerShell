. $PSScriptRoot/../TestHelpers.ps1
Describe 'Submit-SystemInfoTicket.ps1 script' {
    Initialize-TestDrive
    BeforeAll {
        $ScriptPath = Join-Path $PSScriptRoot/../.. 'scripts/Submit-SystemInfoTicket.ps1'
        Import-Module $PSScriptRoot/../../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../../src/IncidentResponseTools/IncidentResponseTools.psd1 -Force
        Import-Module $PSScriptRoot/../../src/SharePointTools/SharePointTools.psd1 -Force
        Import-Module $PSScriptRoot/../../src/ServiceDeskTools/ServiceDeskTools.psd1 -Force
    }
    BeforeEach {
        Mock Get-CommonSystemInfo { @{ OS = 'Windows' } }
        Mock Get-SPToolsSettings { @{ ClientId='id'; TenantId='tid'; CertPath='cert' } }
        Mock Get-SPToolsSiteUrl { 'https://contoso.sharepoint.com/sites/it' }
        Mock Connect-PnPOnline {}
        Mock Add-PnPFile { [pscustomobject]@{ ServerRelativeUrl='/docs/report.json' } }
        Mock New-SDTicket {}
        Mock Send-MailMessage {}
        Mock Write-STStatus {}
    }

    Safe-It 'uses provided SmtpServer when sending email' {
        & $ScriptPath -SiteName 'IT' -RequesterEmail 'user@example.com' -SmtpServer 'smtp.contoso.com' | Out-Null
        Assert-MockCalled Send-MailMessage -Times 1 -ParameterFilter { $SmtpServer -eq 'smtp.contoso.com' }
    }
}
