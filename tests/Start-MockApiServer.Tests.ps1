. $PSScriptRoot/TestHelpers.ps1
Describe 'Start-MockApiServer script' {
    Safe-It 'serves one Graph request and stops' {
        function Write-STStatus { param([string]$Message,[string]$Level) }
        class FakeResponse {
            [System.IO.MemoryStream]$OutputStream = [System.IO.MemoryStream]::new()
            [string]$ContentType
            [int64]$ContentLength64
            [int]$CloseCount = 0
            [void] Close() { $this.CloseCount++ }
        }
        class FakeContext {
            [pscustomobject]$Request
            [FakeResponse]$Response
            FakeContext([string]$url) {
                $this.Request = [pscustomobject]@{ RawUrl = $url }
                $this.Response = [FakeResponse]::new()
            }
        }
        class FakeHttpListener {
            [System.Collections.Specialized.StringCollection]$Prefixes = [System.Collections.Specialized.StringCollection]::new()
            [bool]$IsListening = $true
            [int]$StopCount = 0
            [FakeContext]$Context
            FakeHttpListener([FakeContext]$ctx) { $this.Context = $ctx }
            [void] Start() {}
            [void] Stop() { $this.StopCount++ }
            [FakeContext] GetContext() { $this.IsListening = $false; return $this.Context }
        }
        $listener = [FakeHttpListener]::new([FakeContext]::new('/graph/test'))
        $scriptPath = Join-Path $PSScriptRoot/.. 'scripts/Start-MockApiServer.ps1'
        $code = Get-Content $scriptPath -Raw -Encoding UTF8
        $code = ($code -split "`n") | Where-Object { $_ -notmatch 'Import-Module' } | Out-String
        $code = $code -replace '\[System.Net.HttpListener\]::new\(\)', '$listener'
        & ([scriptblock]::Create($code))
        $listener.StopCount | Should -Be 1
        $listener.Context.Response.OutputStream.Position = 0
        $body = [System.Text.Encoding]::UTF8.GetString($listener.Context.Response.OutputStream.ToArray())
        $body | Should -Match 'fake Graph response'
    }
}
