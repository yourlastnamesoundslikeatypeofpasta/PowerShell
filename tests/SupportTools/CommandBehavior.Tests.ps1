. $PSScriptRoot/../TestHelpers.ps1
Describe 'SupportTools command behaviors' {
    BeforeAll {
        Import-Module $PSScriptRoot/../../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../../src/SupportTools/SupportTools.psd1 -Force
    }

    Safe-It 'Clear-TempFile removes tmp and log files' {
        $repoRoot = Resolve-Path "$PSScriptRoot/../.."
        $dir = Join-Path $repoRoot 'TempTest'
        New-Item -ItemType Directory -Path $dir | Out-Null
        $tmp = New-Item -ItemType File -Path (Join-Path $dir 'a.tmp') -Force
        $log = New-Item -ItemType File -Path (Join-Path $dir 'b.log') -Force
        try {
            $result = Clear-TempFile
            $result.RemovedTmpFileCount | Should -BeGreaterOrEqual 1
            $result.RemovedLogFileCount | Should -BeGreaterOrEqual 1
            Test-Path $tmp | Should -BeFalse
            Test-Path $log | Should -BeFalse
        } finally {
            Remove-Item $dir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    Safe-It 'Convert-ExcelToCsv passes correct path to Excel' {
        InModuleScope SupportTools {
            Mock Import-Csv { @() } -ModuleName SupportTools
            function New-Object { param([string]$ComObject)
                [pscustomobject]@{
                    Workbooks = [pscustomobject]@{
                        Open = { param($p)
                            [pscustomobject]@{
                                Worksheets = @( [pscustomobject]@{ SaveAs = { param($path,$fmt) $script:csvPath = $path } } )
                                Close = { param($s) }
                            }
                        }
                    }
                    Quit = {}
                }
            }
            $file = Join-Path $TestDrive 'book.xlsx'
            Set-Content -Path $file -Value ''
            $null = Convert-ExcelToCsv -XlsxFilePath $file
            $expected = $file -replace '\\.xlsx$','.csv'
            $script:csvPath | Should -Be $expected
        }
    }

    Safe-It 'Export-ProductKey writes key to file' {
        InModuleScope SupportTools {
            Mock Get-CimInstance { [pscustomobject]@{ OA3xOriginalProductKey='AAAAA-BBBBB-CCCCC-DDDDD' } }
            $out = Join-Path $TestDrive 'key.txt'
            try {
                $res = Export-ProductKey -OutputPath $out
                (Get-Content $out) | Should -Be 'AAAAA-BBBBB-CCCCC-DDDDD'
                $res.ProductKey | Should -Be 'AAAAA-BBBBB-CCCCC-DDDDD'
            } finally {
                Remove-Item $out -ErrorAction SilentlyContinue
            }
        }
    }

    Context 'Get-UniquePermission' {
        Safe-It 'accepts pipeline input and forwards arguments' {
            InModuleScope SupportTools {
                Mock Invoke-ScriptFile {} -ModuleName SupportTools
                'arg1','arg2' | Get-UniquePermission
                Assert-MockCalled Invoke-ScriptFile -ModuleName SupportTools -Times 2
            }
        }
        Safe-It 'produces ErrorRecord when script fails' {
            InModuleScope SupportTools {
                function Invoke-ScriptFile { throw 'fail' }
                try { Get-UniquePermission -Arguments 'a' } catch { $err = $_ }
                $err | Should -BeOfType 'System.Management.Automation.ErrorRecord'
            }
        }
    }

    Safe-It 'Start-Countdown loops ten times' {
        InModuleScope SupportTools {
            $count = 0
            Mock Write-STStatus {}
            function Start-Sleep { param([int]$Seconds) $script:count++ }
            Start-Countdown | Out-Null
            $script:count | Should -Be 10
        }
    }

    Context 'Invoke-JobBundle' {
        Safe-It 'passes bundle path to script' {
            InModuleScope SupportTools {
                Mock Compress-Archive {}
                Mock Invoke-ScriptFile {} -ModuleName SupportTools
                Invoke-JobBundle -Path 'job.job.zip' -LogArchivePath 'out.zip'
                Assert-MockCalled Invoke-ScriptFile -ModuleName SupportTools -Times 1 -ParameterFilter {
                    $Name -eq 'Run-JobBundle.ps1' -and $Args -contains '-BundlePath' -and $Args -contains 'job.job.zip'
                }
            }
        }
        Safe-It 'returns ErrorRecord when script fails' {
            InModuleScope SupportTools {
                function Invoke-ScriptFile { throw 'oops' }
                try { Invoke-JobBundle -Path 'bad.job.zip' } catch { $err = $_ }
                $err | Should -BeOfType 'System.Management.Automation.ErrorRecord'
            }
        }
    }

    Safe-It 'New-SPUsageReport forwards parameters' {
        InModuleScope SupportTools {
            Mock Invoke-ScriptFile { 'report.csv' } -ModuleName SupportTools
            $res = New-SPUsageReport -CsvPath 'input.csv' -TranscriptPath 't.log'
            Assert-MockCalled Invoke-ScriptFile -ModuleName SupportTools -Times 1 -ParameterFilter {
                $Args -contains '-CsvPath' -and $Args -contains 'input.csv' -and $TranscriptPath -eq 't.log'
            }
            $res.Result | Should -Be 'report.csv'
        }
    }
}
