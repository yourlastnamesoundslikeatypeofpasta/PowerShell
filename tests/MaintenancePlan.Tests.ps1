. $PSScriptRoot/TestHelpers.ps1
Describe 'MaintenancePlan Module' {
    BeforeAll {
        Import-Module $PSScriptRoot/../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../src/MaintenancePlan/MaintenancePlan.psd1 -Force
    }

    Safe-It 'exports New-MaintenancePlan' {
        (Get-Command -Module MaintenancePlan).Name | Should -Contain 'New-MaintenancePlan'
    }

    Safe-It 'creates and persists a plan' {
        $temp = [System.IO.Path]::GetTempFileName()
        try {
            $plan = New-MaintenancePlan -Name Test -Steps @('Write-Host "hi"')
            $plan | Export-MaintenancePlan -Path $temp
            $imported = Import-MaintenancePlan -Path $temp
            $imported.Name | Should -Be 'Test'
            $imported.Steps[0] | Should -Be 'Write-Host "hi"'
        }
        finally {
            Remove-Item $temp -ErrorAction SilentlyContinue
        }
    }

    Safe-It 'executes script steps' {
        $scriptPath = Join-Path ([IO.Path]::GetTempPath()) 'step.ps1'
        Set-Content $scriptPath '$script:ran = $true'
        try {
            $plan = New-MaintenancePlan -Name Demo -Steps @($scriptPath)
            $script:ran = $false
            Invoke-MaintenancePlan -Plan $plan
            $script:ran | Should -Be $true
        }
        finally {
            Remove-Item $scriptPath -ErrorAction SilentlyContinue
        }
    }

    Safe-It 'shows plan summary' {
        $plan = New-MaintenancePlan -Name Demo -Steps @('step1', 'step2') -Schedule 'Daily'
        { Show-MaintenancePlan -Plan $plan } | Should -Not -Throw
    }

    Safe-It 'builds scheduled task command on Windows' {
        InModuleScope MaintenancePlan {
            Set-Variable -Name IsWindows -Value $true -Scope Script -Force
            function Register-ScheduledTask {}
            function New-ScheduledTaskAction { param($Execute, $Argument) $script:arg = $Argument; [pscustomobject]@{Execute = $Execute; Argument = $Argument } }
            function New-ScheduledTaskTrigger { param([string]$Daily, [string]$At) [pscustomobject]@{At = $At } }
            Schedule-MaintenancePlan -PlanPath '/tmp/p.json' -Cron '5 1 * * *' -Name 'MP'
            $expectedModule = Join-Path (Get-Module MaintenancePlan).ModuleBase 'MaintenancePlan.psd1'
            $script:arg | Should -Match [Regex]::Escape($expectedModule)
            $script:arg | Should -Match '/tmp/p.json'
        }
    }

    Safe-It 'returns cron entry on non-windows' {
        InModuleScope MaintenancePlan {
            Set-Variable -Name IsWindows -Value $false -Scope Script -Force
            $entry = Schedule-MaintenancePlan -PlanPath '/tmp/p.json' -Cron '5 1 * * *' -Name 'MP'
            $expectedModule = Join-Path (Get-Module MaintenancePlan).ModuleBase 'MaintenancePlan.psd1'
            $entry | Should -Match [Regex]::Escape($expectedModule)
            $entry | Should -Match '/tmp/p.json'
        }
    }
}
