Describe 'MaintenancePlan Module' {
    BeforeAll {
        Import-Module $PSScriptRoot/../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../src/MaintenancePlan/MaintenancePlan.psd1 -Force
    }

    It 'exports New-MaintenancePlan' {
        (Get-Command -Module MaintenancePlan).Name | Should -Contain 'New-MaintenancePlan'
    }

    It 'creates and persists a plan' {
        $temp = [System.IO.Path]::GetTempFileName()
        try {
            $plan = New-MaintenancePlan -Name Test -Steps @('Write-Host "hi"')
            $plan | Export-MaintenancePlan -Path $temp
            $imported = Import-MaintenancePlan -Path $temp
            $imported.Name | Should -Be 'Test'
            $imported.Steps[0] | Should -Be 'Write-Host "hi"'
        } finally {
            Remove-Item $temp -ErrorAction SilentlyContinue
        }
    }

    It 'executes script steps' {
        $scriptPath = Join-Path ([IO.Path]::GetTempPath()) 'step.ps1'
        Set-Content $scriptPath '$script:ran = $true'
        try {
            $plan = New-MaintenancePlan -Name Demo -Steps @($scriptPath)
            $script:ran = $false
            Invoke-MaintenancePlan -Plan $plan
            $script:ran | Should -Be $true
        } finally {
            Remove-Item $scriptPath -ErrorAction SilentlyContinue
        }
    }
}
