function Add-UserToGroup {
    <#
    .SYNOPSIS
        Adds users from a CSV file to a Microsoft 365 group.
    .DESCRIPTION
        Implements the AddUsersToGroup script logic directly so the script file
        is now only a thin wrapper.
    .PARAMETER CsvPath
        Path to the CSV file containing user principal names.
    .PARAMETER GroupName
        Name of the Microsoft 365 group to modify.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$CsvPath,
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$GroupName
    )

    begin {
        . (Join-Path $PSScriptRoot '../..' 'scripts/Common.ps1')
        Import-SupportToolsLogging
        Add-Type -AssemblyName PresentationFramework, System.Windows.Forms
        $InformationPreference = 'Continue'
    }

    process {
        function Get-CSVFilePath {
            Write-STStatus 'Select CSV from file dialog...' -Level SUB
            $openFileDialog = New-Object Microsoft.Win32.OpenFileDialog
            $openFileDialog.InitialDirectory = [Environment]::GetFolderPath('MyDocuments')
            $openFileDialog.Filter = 'CSV files (*.csv)|*.csv|All files (*.*)|*.*'
            if ($openFileDialog.ShowDialog() -eq 'True') {
                return Get-ChildItem -Path $openFileDialog.FileName
            } else {
                Write-STStatus 'No file selected' -Level SUB
                return $null
            }
        }

        function Get-GroupNames {
            Get-MgGroup -All | Select-Object DisplayName, Id
        }

        function Connect-MicrosoftGraph {
            Write-STStatus 'Connecting to Microsoft Graph...' -Level INFO
            $scopes = 'User.Read.All','Group.ReadWrite.All','Directory.ReadWrite.All'
            Connect-MgGraph -Scopes $scopes -NoWelcome
            $account = (Get-MgContext).Account
            Write-STStatus "Microsoft Graph Account: $account" -Level INFO
            Write-STStatus ('-' * $account.Length) -Level INFO
        }

        function Get-Group {
            param([string]$Name)
            if ($Name) {
                $grp = Get-MgGroup -Filter "displayName eq '$Name'" | Select-Object -First 1
                if (-not $grp) { throw "Group '$Name' not found." }
                Write-STStatus "Using group: $($grp.DisplayName)" -Level SUB
                return $grp
            }
            $allGroupNames = Get-GroupNames | Sort-Object -Property DisplayName
            $index = 0
            foreach ($group in $allGroupNames) {
                Write-STStatus "[$index] - $($group.DisplayName)" -Level INFO
                $index++
            }
            $selection = Read-Host -Prompt 'Select a group'
            $selected = $allGroupNames[$selection]
            Write-STStatus "You have selected: $($selected.DisplayName)" -Level SUB
            $selected
        }

        function Get-GroupExistingMembers {
            param($Group)
            $existingMembers = Get-MgGroupMember -GroupId $group.Id
            $list = [System.Collections.Generic.List[object]]::new()
            foreach ($id in $existingMembers.Id) {
                $UPN = Get-MgUser -UserId $id | Select-Object -ExpandProperty UserPrincipalName
                $list.Add($UPN)
            }
            $list
        }

        function Get-UserID {
            param([string]$UserPrincipalName)
            try {
                Get-MgUser -UserId $UserPrincipalName -ErrorAction Stop
            } catch {
                Write-STStatus "User not found: $UserPrincipalName" -Level WARN
                return $null
            }
        }

        function Start-Main {
            param(
                [string]$CsvPath,
                [string]$GroupName
            )
            Connect-MicrosoftGraph -ErrorAction Stop
            $group = Get-Group -Name $GroupName
            $groupExistingMembers = Get-GroupExistingMembers -Group $group
            if (-not $CsvPath) { $CsvPath = Get-CSVFilePath }
            $file = Import-Csv $CsvPath
            $users = $file.UPN
            $addedUsers = @()
            $skippedUsers = @()
            foreach ($user in $users) {
                $userInfo = Get-UserID -UserPrincipalName $user
                if (-not $userInfo) {
                    $skippedUsers += $user
                    continue
                }
                if ($groupExistingMembers -contains $userInfo.UserPrincipalName) {
                    Write-STStatus "UserIsInGroup: $user - $($group.DisplayName)" -Level WARN
                    $skippedUsers += $userInfo.UserPrincipalName
                } else {
                    Write-STStatus "AddingUserToGroup: User: $($userInfo.DisplayName) - Group: $($group.DisplayName)" -Level INFO
                    New-MgGroupMember -GroupId $group.Id -DirectoryObjectId $userInfo.Id -ErrorAction Stop
                    $addedUsers += $userInfo.UserPrincipalName
                }
            }
            Disconnect-MgGraph | Out-Null
            [pscustomobject]@{
                GroupName    = $group.DisplayName
                AddedUsers   = $addedUsers
                SkippedUsers = $skippedUsers
            }
        }

        Start-Main -CsvPath $CsvPath -GroupName $GroupName
    }
}
