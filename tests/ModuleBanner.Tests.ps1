$base = Join-Path $PSScriptRoot '..'
$Cases = @(
    @{ Name='STCore'; Function='Show-STCoreBanner'; Psd1=Join-Path $base 'src/STCore/STCore.psd1' }
    @{ Name='Logging'; Function='Show-LoggingBanner'; Psd1=Join-Path $base 'src/Logging/Logging.psd1' }
    @{ Name='Telemetry'; Function='Show-TelemetryBanner'; Psd1=Join-Path $base 'src/Telemetry/Telemetry.psd1' }
    @{ Name='ServiceDeskTools'; Function='Show-ServiceDeskToolsBanner'; Psd1=Join-Path $base 'src/ServiceDeskTools/ServiceDeskTools.psd1' }
    @{ Name='SharePointTools'; Function='Show-SharePointToolsBanner'; Psd1=Join-Path $base 'src/SharePointTools/SharePointTools.psd1' }
    @{ Name='ConfigManagementTools'; Function='Show-ConfigManagementToolsBanner'; Psd1=Join-Path $base 'src/ConfigManagementTools/ConfigManagementTools.psd1' }
    @{ Name='IncidentResponseTools'; Function='Show-IncidentResponseToolsBanner'; Psd1=Join-Path $base 'src/IncidentResponseTools/IncidentResponseTools.psd1' }
    @{ Name='SupportTools'; Function='Show-SupportToolsBanner'; Psd1=Join-Path $base 'src/SupportTools/SupportTools.psd1' }
    @{ Name='MonitoringTools'; Function='Show-MonitoringToolsBanner'; Psd1=Join-Path $base 'src/MonitoringTools/MonitoringTools.psd1' }
    @{ Name='PerformanceTools'; Function='Show-PerformanceToolsBanner'; Psd1=Join-Path $base 'src/PerformanceTools/PerformanceTools.psd1' }
    @{ Name='MaintenancePlan'; Function='Show-MaintenancePlanBanner'; Psd1=Join-Path $base 'src/MaintenancePlan/MaintenancePlan.psd1' }
    @{ Name='ChaosTools'; Function='Show-ChaosToolsBanner'; Psd1=Join-Path $base 'src/ChaosTools/ChaosTools.psd1' }
)

Describe 'Module Banner Functions' {
    BeforeAll {
        foreach ($case in $Cases) {
            $case.ModuleObject = Import-Module $case.Psd1 -Force -PassThru
        }
    }

    It 'returns correct banner for <Name> and exports <Function>' -ForEach $Cases {
        param($case)
        $sb = [scriptblock]::Create($case.Function)
        $result = $case.ModuleObject.NewBoundScriptBlock($sb).Invoke()
        $manifest = Import-PowerShellDataFile $case.Psd1
        $result.Module  | Should -Be $case.Name
        $result.Version | Should -Be $manifest.ModuleVersion
        Get-Command -Module $case.Name -Name $case.Function | Should -Not -BeNullOrEmpty
    }
}
