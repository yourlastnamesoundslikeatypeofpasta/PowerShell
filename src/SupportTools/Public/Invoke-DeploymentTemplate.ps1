function Invoke-DeploymentTemplate {
# <#
# .SYNOPSIS
# Template script for sneaker net deployments.
#
# .DESCRIPTION
# Provides functions to confirm service status, export client data,
# install agents and software, copy files, set power plans and join a
# computer to the domain. The script acts as a starting point for custom
# deployments executed from a network share.
# #>

<#
- Confirm services running:
    - Sysmon
    - [REDACTED]
    - [REDACTED]
- Export Object Data:
    - Get-Service
    - Get-NetAdapter
    - Get-NetAdapterStatistics
    - Get-NetIPConfiguration
#>


function Install-Something {
    param (
        [Parameter()]
        [string]
        $ServerSharePath,

        [Parameter()]
        [string]
        $FilePath,

        [Parameter()]
        [string]
        $Arguments
    )
    $ServerFilePath = "\\$($ServerSharePath)\$($FilePath)"
    Start-Process -FilePath $ServerFilePath -Wait -ArgumentList $Arguments
}

function Confirm-ServiceRunning {
    [CmdletBinding()]
    param (
        [Parameter()]
        [array]
        $ServiceList
    )

    # add default services to confirm to $ServiceList
    $defaultServiceList = @(
        'Sysmon64'
        '[REDACTED]'
        '[REDACTED]'
    )
    $ServiceList += $defaultServiceList

    # confirm services
    foreach ($service in $ServiceList) {
        $currentService = Get-Service -Name $service
        $currentServiceDisplayName = $currentService.DisplayName
        $currentServiceStatus = $currentService.Status
        $runningStatusCode = 'Running'
        $isCurrentServiceRunning = $currentServiceStatus -eq $runningStatusCode
    
        # confirm sentinal is running
        if ($isCurrentServiceRunning) {
            Write-Information -MessageData "$($currentServiceDisplayName) - Running" -InformationAction Continue
        }
        else {
            Write-Warning -Message "$($currentServiceDisplayName) - NOT RUNNING!!!"
        }
    }
}

function Export-Client {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $ServerSharePath,

        [Parameter()]
        [array]
        $ScriptBlockArray,

        [Parameter()]
        [string]
        $UpdateVersion
    )


    # default client properties to export
    $clientObjectProperties = @{
        ComputerName = $env:COMPUTERNAME
        SSUpdateApplied = $UpdateVersion
        date = Get-Date
        getService = Get-Service
        getProcess = Get-Process
        getNetAdapter = Get-NetAdapter
        getNetAdapterStatistics = Get-NetAdapterStatistics
        getNetIPConfiguration = Get-NetIPConfiguration
        getDNSClientServerAddress = Get-DnsClientServerAddress
        }
    
    # add the results of each scriptblock within scriptBlockArray to clientObjectProperties
    foreach ($ScriptBlock in $ScriptBlockArray) {
        $commandPropertyName = $ScriptBlock.ToString().Split('-') -join ''
        Write-Information -MessageData "Capturing Command Data - $commandPropertyName" -InformationAction Continue
        $commandResults = Invoke-Command $ScriptBlock
        $clientObjectProperties.Add($commandPropertyName, $commandResults)
    }
    
    $clientObject = [pscustomobject]$clientObjectProperties

    # save xml to ServerSharePath logs dir, create the update dir within the logs dir if it doesn't exist
    $xmlExportDir = "\\$($ServerSharePath)\logs\$($UpdateVersion)"
    $isXmlExportDir = Test-Path $xmlExportDir
    if (!$isXmlExportDir){
        New-Item -Path $xmlExportDir -ItemType Directory | Out-Null
    }
    $xmlExportPath = "$($xmlExportDir)\$($ComputerName)_$($UpdateVersion).xml"
    $clientObject | Export-Clixml $xmlExportPath
}

function Get-WHVersions {
    [CmdletBinding()]
    param (
        [Parameter()]
        [switch]
        $Shipping,
        [Parameter()]
        [switch]
        $Login
    )
    Write-Information -MessageData 'Getting production file versions...' -InformationAction Continue
    $loginFileHashDict = @{
        whLogProductionHash = '39B316E7C273F032999EFCD14A382B649F155039B843784EC6CA99BB553F5BEE'
        rmLogProductionHash = 'D2E331FD7ACF00836A1DE19BA73FD0C3ACFAD9EF1EFE7CEEDA1DBFB8C87E9860'
        csLogProductionHash = '0EA0B11BE928CF7325224A2B3C08CBEC90BBFE508F39C1AE9EE4FB822B8C53AD' 
    }

    $shipFileHashDict = @{
        whShipProductionHash = 'DAC8F04F246D5CB678E7C5931F52C99C5CC367B8EC5DF360C45F3C1FB381220B'
        csShipProductionHash = '0EA0B11BE928CF7325224A2B3C08CBEC90BBFE508F39C1AE9EE4FB822B8C53AD'
    }

    $loginFileList = @(
        'warehouse.exe'
        'connectionstrings.config'
        'receivingmanifest.exe'
        )
    
    $shipFileList = @(
        'warehouse.exe'
        'connectionstrings.config'
    )

    if ($Login){
        $fileHashDict = $loginFileHashDict
        $fileList = $loginFileList
    }
    elseif ($Shipping) {
        $fileHashDict = $shipFileHashDict
        $fileList = $shipFileList
    }
    else {
        $fileHashDict = $loginFileHashDict + $shipFileHashDict
        $fileList = $loginFileList + $shipFileList
    }

    $foundFileList = [System.Collections.Generic.List[object]]::new()
    foreach ($file in $fileList) {
        $foundFiles = Get-ChildItem -Path "C:\Users\*\$($file)" -Recurse -Force -ErrorAction SilentlyContinue
        $foundFileList.add($foundFiles)
    }

    $foundFileHashList = $foundFileList | Get-FileHash
    
    # check hash of each warehouse version
    # compare hash against current production hash
    $isFileProdList = [System.Collections.Generic.List[object]]::new()
    foreach ($file in $foundFileHashList) {
        $path = $file.Path
        $hash = $file.Hash
        $isFileProd = $false
        if ($fileHashDict.Values -contains $hash) {
            $isFileProd = $true
        }
        
        # create custom file production status object
        $lastFourOfHash = $hash[-4..-1] -join ''
        $whProductionStatusHashtable = @{
            Path = $path
            'Hash (Last Four)' = $lastFourOfHash
            'Production' = $isFileProd
        }
        $whProductionStatusObj = [PSCustomObject]$whProductionStatusHashtable
        $isFileProdList.Add($whProductionStatusObj)
        
    } # ENDFOR
    
    return $isFileProdList
}

function Get-ServerSharePath {
    [CmdletBinding()]
    param (
        [Parameter()]
        [switch]
        $Login,
        [Parameter()]
        [switch]
        $Ship
    )
    if ($Login) {
        $loginServerSharePath = 'CRP-[REDACTED]\D$'
        return $loginServerSharePath
    }
    if ($Ship) {
        $shipServerSharePath = 'CRP-[REDACTED]\D$'
        return $shipServerSharePath
    }
}

function Get-UpdateVersion {
    [CmdletBinding()]
    param (
        [Parameter()]
        [switch]
        $Login,
        [Parameter()]
        [switch]
        $Ship
    )
    $formattedDate = Get-Date -Format Mdy
    if ($Login) {
        $loginUpdateVersion = "LOGIN_SS_$($formattedDate)"
        return $loginUpdateVersion
    }
    if ($Ship) {
        $shipServerSharePath = "SHIP_SS_$($formattedDate)"
        return $shipServerSharePath
    }
}

function Set-Signoff {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $ServerSharePath
    )
    $filePath = "\\$($serverSharePath)\assets\mermaidMan.jpg"
    [void][reflection.assembly]::LoadWithPartialName("System.Windows.Forms")

    $file = (get-item $filePath)
    $img = [System.Drawing.Image]::Fromfile($file);

    [System.Windows.Forms.Application]::EnableVisualStyles();
    $form = new-object Windows.Forms.Form
    $form.Text = "Image Viewer"
    $form.Width = $img.Size.Width;
    $form.Height =  $img.Size.Height;
    $pictureBox = new-object Windows.Forms.PictureBox
    $pictureBox.Width =  $img.Size.Width;
    $pictureBox.Height =  $img.Size.Height;

    $pictureBox.Image = $img;
    $form.controls.add($pictureBox)
    $form.Add_Shown( { $form.Activate() } )
    $form.ShowDialog()    
}

$serverSharePath = Get-ServerSharePath -Login -Ship
$updateVersion = Get-UpdateVersion -Login -Ship


}
