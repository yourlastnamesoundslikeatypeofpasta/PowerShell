Describe 'MaintenancePlan Module' {
    BeforeAll {
        Import-Module $PSScriptRoot/../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../src/MaintenancePlan/MaintenancePlan.psd1 -Force
    }

    It 'exports New-MaintenancePlan' {
        (Get-Command -Module MaintenancePlan).Name | Should -Contain 'New-MaintenancePlan'
    }

    It 'exports Export-MaintenancePlan' {
        (Get-Command -Module MaintenancePlan).Name | Should -Contain 'Export-MaintenancePlan'
    }

    It 'exports Import-MaintenancePlan' {
        (Get-Command -Module MaintenancePlan).Name | Should -Contain 'Import-MaintenancePlan'
    }

    It 'round trips a plan to JSON' {
        $plan = New-MaintenancePlan -Name 'Test' -Tasks 'Write-Host' -Schedule 'Daily'
        $temp = [System.IO.Path]::GetTempFileName()
        try {
            Export-MaintenancePlan -Plan $plan -Path $temp
            $loaded = Import-MaintenancePlan -Path $temp
            $loaded.Name | Should -Be 'Test'
            $loaded.Tasks[0] | Should -Be 'Write-Host'
            $loaded.Schedule | Should -Be 'Daily'
        } finally {
            Remove-Item $temp -ErrorAction SilentlyContinue
        }
    }
}
