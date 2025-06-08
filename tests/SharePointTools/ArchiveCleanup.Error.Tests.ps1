Describe 'Invoke-ArchiveCleanup error handling' {
    BeforeAll {
        Import-Module $PSScriptRoot/../../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../../src/SharePointTools/SharePointTools.psd1 -Force
    }
    It 'logs when file removal fails' {
        InModuleScope SharePointTools {
            $ExecutionContext.SessionState.PSVariable.Set('SharePointToolsSettings', @{ Sites = @{ A='https://contoso' }; ClientId='id'; TenantId='tid'; CertPath='c' })
            function Connect-PnPOnline { param($Url,$ClientId,$Tenant,$CertificatePath) }
            function Get-PnPListItem {
                @([pscustomobject]@{ FileSystemObjectType='File'; FieldValues=@{ FileRef='Shared Documents/zzz_Archive/f.txt' } })
            }
            function Remove-PnPFile {}
            function Remove-PnPFolder {}
            Mock Connect-PnPOnline {}
            Mock Remove-PnPFile { throw 'oops' }
            Mock Remove-PnPFolder {}
            Mock Start-Transcript {}
            Mock Stop-Transcript {}
            Mock Write-STStatus {} -ParameterFilter { $Message -like '*FILE DELETE FAIL*' }
            Invoke-ArchiveCleanup -SiteName 'A' -SiteUrl 'https://contoso' -Confirm:$false | Out-Null
            Assert-MockCalled Write-STStatus -ParameterFilter { $Message -like '*FILE DELETE FAIL*' } -Times 1
        }
    }
}
