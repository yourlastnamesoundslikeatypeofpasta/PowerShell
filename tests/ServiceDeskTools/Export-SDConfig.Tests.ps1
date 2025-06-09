. $PSScriptRoot/../TestHelpers.ps1

Describe 'Export-SDConfig' {
    Initialize-TestDrive
    BeforeAll {
        Import-Module $PSScriptRoot/../../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../../src/ServiceDeskTools/ServiceDeskTools.psd1 -Force
    }

    Safe-It 'exports env settings without API token' {
        InModuleScope ServiceDeskTools {
            $temp = [System.IO.Path]::GetTempFileName()
            try {
                $env:SD_BASE_URI = 'https://desk.example.com/api'
                $env:SD_ASSET_BASE_URI = 'https://assets.example.com/api'
                $env:SD_RATE_LIMIT_PER_MINUTE = '17'
                $env:SD_API_TOKEN = 'secret'

                Export-SDConfig -Path $temp
                $json = Get-Content $temp | ConvertFrom-Json
                $json.BaseUri | Should -Be 'https://desk.example.com/api'
                $json.AssetBaseUri | Should -Be 'https://assets.example.com/api'
                $json.RateLimitPerMinute | Should -Be 17
                $json.PSObject.Properties.Name | Should -Not -Contain 'ApiToken'
            }
            finally {
                Remove-Item $temp -ErrorAction SilentlyContinue
                Remove-Item env:SD_BASE_URI -ErrorAction SilentlyContinue
                Remove-Item env:SD_ASSET_BASE_URI -ErrorAction SilentlyContinue
                Remove-Item env:SD_RATE_LIMIT_PER_MINUTE -ErrorAction SilentlyContinue
                Remove-Item env:SD_API_TOKEN -ErrorAction SilentlyContinue
            }
        }
    }
}
