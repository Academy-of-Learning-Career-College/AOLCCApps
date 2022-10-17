$arg = "Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/fireball8931/AOLCCApps/master/Set-UserFTAAdobePDF.ps1'))"


$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument $arg

$trigger = New-ScheduledTaskTrigger -Daily -At 6am 

$taskPrincipal = New-ScheduledTaskPrincipal -RunLevel Limited -LogonType 


$task = Register-ScheduledTask -Action $action -Trigger $trigger -TaskPath "AdminTasks" -TaskName "Set Adobe Reader Default PDF 1" -Description "This task sets adobe reader as the default 3 times per day"
$trigger2 = New-ScheduledTaskTrigger -Daily -At 12pm 
Add-JobTrigger -Trigger $trigger2 -InputObject $task
$trigger3 = New-ScheduledTaskTrigger -Daily -At 6pm 
Add-JobTrigger -Trigger $trigger3 -InputObject $task
$trigger4 = New-ScheduledTaskTrigger -Daily -At 12am 
Add-JobTrigger -Trigger $trigger4 -InputObject $task

