$loggingModule = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath 'Logging/Logging.psd1'
Import-Module $loggingModule -ErrorAction SilentlyContinue

function Summarize-AuditFindings {
    <#
    .SYNOPSIS
        Summarizes audit results using an OpenAI-compatible API.
    .DESCRIPTION
        Sends structured audit data to an API endpoint such as Azure OpenAI or a local service
        and returns a plain-language executive summary with bullet points and recommended remediations.
    .PARAMETER InputObject
        Audit data object or JSON string. Accepts pipeline input.
    .PARAMETER EndpointUri
        API endpoint URI. Defaults to the ST_OPENAI_ENDPOINT environment variable.
    .PARAMETER ApiKey
        API authentication key. Defaults to the ST_OPENAI_KEY environment variable.
    .PARAMETER Model
        Model name for the API request. Defaults to gpt-3.5-turbo.
    .PARAMETER SystemMessage
        Custom system prompt describing the assistant's role.
    .PARAMETER Template
        Prompt template containing a {data} placeholder for the JSON payload.
    .PARAMETER Format
        Output format for the summary: Text, Markdown or Html.
    .PARAMETER OutputPath
        Optional path to save the summary output.
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$true)]
        [object]$InputObject,
        [string]$EndpointUri,
        [string]$ApiKey,
        [string]$Model = 'gpt-3.5-turbo',
        [string]$SystemMessage = 'You summarize audit findings for executives.',
        [string]$Template = 'Summarize the following audit findings in plain language with bullet points and remediation steps:\n{data}',
        [ValidateSet('Text','Markdown','Html')]
        [string]$Format = 'Text',
        [string]$OutputPath
    )
    begin { $items = @() }
    process {
        if ($null -ne $InputObject) {
            if ($InputObject -is [string]) {
                try { $items += ($InputObject | ConvertFrom-Json -ErrorAction Stop) }
                catch { $items += $InputObject }
            } else {
                $items += $InputObject
            }
        }
    }
    end {
        if (-not $EndpointUri) { $EndpointUri = $env:ST_OPENAI_ENDPOINT }
        if (-not $ApiKey) { $ApiKey = $env:ST_OPENAI_KEY }
        if (-not $EndpointUri) { throw 'EndpointUri is required.' }
        if (-not $ApiKey) { throw 'ApiKey is required.' }

        $json = $items | ConvertTo-Json -Depth 10
        $prompt = $Template -replace '{data}', $json

        $body = @{ model = $Model; messages = @(
            @{ role = 'system'; content = $SystemMessage }
            @{ role = 'user'; content = $prompt }
        ) } | ConvertTo-Json -Depth 10

        $headers = @{ Authorization = "Bearer $ApiKey" }

        Write-STLog -Message 'Summarizing audit findings' -Metadata @{endpoint=$EndpointUri}
        $response = Invoke-RestMethod -Uri $EndpointUri -Method Post -Body $body -ContentType 'application/json' -Headers $headers
        $summary = $response.choices[0].message.content

        if ($Format -eq 'Html') {
            $output = ConvertTo-Html -Title 'Audit Summary' -Body $summary
        } else {
            $output = $summary
        }

        if ($OutputPath) { Set-Content -Path $OutputPath -Value $output }
        return $output
    }
}

Export-ModuleMember -Function 'Summarize-AuditFindings'

function Show-AuditToolsBanner {
    Write-STDivider 'AUDITTOOLS MODULE LOADED' -Style heavy
    Write-STStatus "Run 'Get-Command -Module AuditTools' to view available tools." -Level SUB
    Write-STLog -Message 'AuditTools module loaded'
}

Show-AuditToolsBanner
