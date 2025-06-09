. $PSScriptRoot/TestHelpers.ps1
Describe 'Logging UI Functions' {
    BeforeAll {
        Import-Module $PSScriptRoot/../src/Logging/Logging.psd1 -Force
    }

    Safe-It 'formats shell prompt output' {
        $oldUser = $env:USERNAME
        $oldComp = $env:COMPUTERNAME
        try {
            $env:USERNAME = 'tester'
            $env:COMPUTERNAME = 'demo'
            { Show-STPrompt -Command './script.ps1' -Path '/tmp' } |
                Should -Output '┌──(tester@demo)-[/tmp]', '└─$ ./script.ps1'
        }
        finally {
            if ($null -ne $oldUser) { $env:USERNAME = $oldUser } else { Remove-Item env:USERNAME -ErrorAction SilentlyContinue }
            if ($null -ne $oldComp) { $env:COMPUTERNAME = $oldComp } else { Remove-Item env:COMPUTERNAME -ErrorAction SilentlyContinue }
        }
    }

    Safe-It 'renders dividers for light and heavy styles' {
        function Get-ExpectedDivider($title, $style) {
            $char = if ($style -eq 'heavy') { '═' } else { '─' }
            $total = 65
            $padding = $total - $title.Length - 4
            if ($padding -lt 0) { $padding = 0 }
            $half = [math]::Floor($padding / 2)
            return ($char * $half) + "[ $title ]" + ($char * ($padding - $half))
        }
        $expectedLight = Get-ExpectedDivider 'TITLE' 'light'
        { Write-STDivider -Title 'TITLE' -Style 'light' } | Should -Output $expectedLight
        $expectedHeavy = Get-ExpectedDivider 'TITLE' 'heavy'
        { Write-STDivider -Title 'TITLE' -Style 'heavy' } | Should -Output $expectedHeavy
    }

    Safe-It 'aligns block fields correctly' {
        $data = @{ Name = 'Alice'; Email = 'alice@example.com'; Dept = 'IT' }
        function FormatBlock([hashtable]$d) {
            $max = ($d.Keys | Measure-Object -Property Length -Maximum).Maximum
            foreach ($k in $d.Keys) {
                $label = ($k + ':').PadRight($max + 1)
                "> $label $($d[$k])"
            }
        }
        $expected = FormatBlock $data
        { Write-STBlock -Data $data } | Should -Output $expected
    }

    Safe-It 'prints closing banner with custom message' {
        { Write-STClosing -Message 'Done' } | Should -Output '┌──[ Done ]──────────────'
    }

    Safe-It 'returns module name and version' {
        $banner = Show-LoggingBanner
        $banner.Module | Should -Be 'Logging'
        $banner.Version | Should -Not -BeNullOrEmpty
    }

    Safe-It 'filters messages below ST_LOG_LEVEL' {
        try {
            $env:ST_LOG_LEVEL = 'WARN'
            { Write-STStatus -Message 'info hidden' -Level INFO } | Should -BeNullOrEmpty
            { Write-STStatus -Message 'show warn' -Level WARN } | Should -Output '[!] show warn'
        }
        finally {
            Remove-Item env:ST_LOG_LEVEL -ErrorAction SilentlyContinue
        }
    }
}
