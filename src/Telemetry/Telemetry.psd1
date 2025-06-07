@{
    RootModule = 'Telemetry.psm1'
    ModuleVersion = '1.1.0'
    GUID = 'b6b7e080-4ad4-4d58-8b8c-000000000011'
    Author = 'Contoso'
    Description = 'Telemetry utilities.'
    FunctionsToExport = @('Write-STTelemetryEvent','Get-STTelemetryMetrics','Send-STMetric')
}
