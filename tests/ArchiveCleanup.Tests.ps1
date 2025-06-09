. $PSScriptRoot/TestHelpers.ps1
Describe 'Invoke-ArchiveCleanup' {
    BeforeAll {
        if (Get-PSDrive -Name TestDrive -ErrorAction SilentlyContinue) {
            Remove-PSDrive -Name TestDrive -Force
        }
        Import-Module $PSScriptRoot/../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../src/SharePointTools/SharePointTools.psd1 -Force
    }
    BeforeEach {
        InModuleScope SharePointTools {
            $SharePointToolsSettings.ClientId = 'id'
            $SharePointToolsSettings.TenantId = 'tid'
            $SharePointToolsSettings.CertPath = 'cert.pfx'
            function Connect-PnPOnline {}
            function Get-PnPListItem { $script:testItems }
            function Remove-PnPFile {}
            function Remove-PnPFolder {}
            Set-Variable -Scope Script -Name SharePointToolsSettings -Value @{ ClientId = 'id'; TenantId = 'tid'; CertPath = 'path'; Sites = @{} }
            Mock Connect-PnPOnline {}
            Mock Get-PnPListItem { $script:testItems }
            Mock Remove-PnPFile {}
            Mock Remove-PnPFolder {}
            Mock Start-Transcript {}
            Mock Stop-Transcript {}
            Mock Get-SPToolsSiteUrl { 'https://contoso' }
        }
    }
    Safe-It 'removes archived files and folders' {
        InModuleScope SharePointTools {
            $script:testItems = @(
                [pscustomobject]@{ FileSystemObjectType = 'File'; FieldValues = @{ FileRef = 'Shared Documents/zzz_Archive/file.txt' } },
                [pscustomobject]@{ FileSystemObjectType = 'Folder'; FieldValues = @{ FileRef = 'Shared Documents/zzz_Archive/sub'; FileDirRef = 'Shared Documents/zzz_Archive'; FileLeafRef = 'sub' } }
            )
            Invoke-ArchiveCleanup -SiteName 'SiteA' -SiteUrl 'https://contoso' -Confirm:$false | Out-Null
            Assert-MockCalled Remove-PnPFile -Times 1
            Assert-MockCalled Remove-PnPFolder -Times 1
        }
    }

    Safe-It 'suppresses telemetry when NoTelemetry is used' {
        InModuleScope SharePointTools {
            $script:testItems = @()
            Mock Write-STTelemetryEvent {} -ModuleName SharePointTools
            Invoke-ArchiveCleanup -SiteName 'SiteA' -SiteUrl 'https://contoso' -NoTelemetry -Confirm:$false | Out-Null
            Assert-MockCalled Write-STTelemetryEvent -ModuleName SharePointTools -Times 0
        }
    }
}
