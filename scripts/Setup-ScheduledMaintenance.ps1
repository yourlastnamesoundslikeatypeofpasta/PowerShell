<#
.SYNOPSIS
    Creates scheduled tasks for SupportTools maintenance.
.DESCRIPTION
    Generates Task Scheduler XML definitions for weekly cleanup, group maintenance
    and permission audit tasks. The XML is created dynamically and can be written
    to files or registered directly.
.PARAMETER Register
    If specified, the tasks are registered using Register-ScheduledTask. Without
    this switch the XML files are output to the current directory.
#>
[CmdletBinding()]
param(
    [switch]$Register
)

Import-Module (Join-Path $PSScriptRoot '..' 'src/Logging/Logging.psd1') -ErrorAction SilentlyContinue

function New-MaintenanceTaskXml {
    param(
        [Parameter(Mandatory)][string]$TaskName,
        [Parameter(Mandatory)][string]$ScriptPath,
        [string]$Day = 'Sunday',
        [string]$Time = '03:00'
    )

    $start = (Get-Date -Format 'yyyy-MM-dd') + "T$Time:00"
    $triggerXml = @"
  <Triggers>
    <CalendarTrigger>
      <StartBoundary>$start</StartBoundary>
      <ScheduleByWeek>
        <DaysOfWeek><$Day/></DaysOfWeek>
        <WeeksInterval>1</WeeksInterval>
      </ScheduleByWeek>
    </CalendarTrigger>
  </Triggers>
"@

    $encodedScript = $ScriptPath.Replace('&','&amp;')
    $xml = @"
<Task xmlns='http://schemas.microsoft.com/windows/2004/02/mit/task'>
  <RegistrationInfo><Description>$TaskName</Description></RegistrationInfo>
  $triggerXml
  <Principals>
    <Principal id='Author'>
      <LogonType>InteractiveToken</LogonType>
      <RunLevel>LeastPrivilege</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
  </Settings>
  <Actions Context='Author'>
    <Exec>
      <Command>powershell.exe</Command>
      <Arguments>-NoProfile -ExecutionPolicy Bypass -File "$encodedScript"</Arguments>
    </Exec>
  </Actions>
</Task>
"@
    return $xml
}

$repo = Split-Path $PSScriptRoot -Parent
$tasks = @{
    'Weekly Cleanup'    = Join-Path $repo 'scripts' 'CleanupTempFiles.ps1'
    'Group Maintenance' = Join-Path $repo 'scripts' 'AddUsersToGroup.ps1'
    'Permission Audit'  = Join-Path $repo 'scripts' 'Get-UniquePermissions.ps1'
}

foreach ($name in $tasks.Keys) {
    $xml = New-MaintenanceTaskXml -TaskName $name -ScriptPath $tasks[$name]
    if ($Register) {
        Write-STStatus "Registering task $name" -Level INFO -Log
        Register-ScheduledTask -TaskName $name -Xml $xml -Force | Out-Null
    } else {
        $file = "$($name -replace ' ', '')Task.xml"
        Write-STStatus "Writing $file" -Level INFO -Log
        $xml | Set-Content -Path $file -Encoding UTF8
    }
}
