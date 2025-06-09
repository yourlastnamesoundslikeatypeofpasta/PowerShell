function Invoke-SDRestWithRetry {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Method,
        [Parameter(Mandatory)][string]$Uri,
        [hashtable]$Headers,
        [string]$Body
    )
    $maxRetries = 3
    $attempt = 1
    while ($true) {
        try {
            if ($null -ne $Body) {
                $response = Invoke-RestMethod -Method $Method -Uri $Uri -Headers $Headers -Body $Body -ContentType 'application/json'
            }
            else {
                $response = Invoke-RestMethod -Method $Method -Uri $Uri -Headers $Headers
            }
            Write-STLog -Message "SUCCESS $Method $Uri" -Structured:$($env:ST_LOG_STRUCTURED -eq '1')
            return $response
        }
        catch [System.Net.WebException], [Microsoft.PowerShell.Commands.HttpResponseException] {
            $status = $_.Exception.Response.StatusCode.value__
            $msg = $_.Exception.Message
            Write-STLog -Message "HTTP $status $msg" -Level 'ERROR' -Structured:$($env:ST_LOG_STRUCTURED -eq '1')
            if ($status -eq 429 -or ($status -ge 500 -and $status -lt 600)) {
                if ($attempt -lt $maxRetries) {
                    $retryAfter = $_.Exception.Response.Headers['Retry-After']
                    if ($retryAfter) { $delay = [int]$retryAfter } else { $delay = [math]::Pow(2, $attempt) }
                    Write-STLog -Message "Retry $attempt in $delay sec" -Level WARN -Structured:$($env:ST_LOG_STRUCTURED -eq '1')
                    Write-Verbose "Retrying in $delay seconds"
                    Start-Sleep -Seconds $delay
                    $attempt++
                    continue
                }
            }
            $errorObj = New-STErrorObject -Message "HTTP $status $msg" -Category 'HTTP'
            throw $errorObj
        }
        catch {
            Write-STLog -Message "ERROR $Method $Uri :: $_" -Level 'ERROR' -Structured:$($env:ST_LOG_STRUCTURED -eq '1')
            throw
        }
    }
}
