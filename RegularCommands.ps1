#global variables
$externalip = (Invoke-WebRequest -Uri "http://ifconfig.me/ip" -UseBasicParsing).Content
$langleyip = '66.183.1.50'
$abbyip = '66.183.152.124'

#Actual Commands File
#check disk size
if ((Get-Volume -DriveLetter C).SizeRemaining / (1e+9) -lt "1"){
Write-Host Adjusting Volumes
# Variable specifying the drive you want to extend
$drive_letter = "C"
# Script to get the partition sizes and then resize the volume
$size = (Get-PartitionSupportedSize -DriveLetter $drive_letter)
Resize-Partition -DriveLetter $drive_letter -Size $size.SizeMax
}

#Schedule a twice daily reboot
$action = New-ScheduledTaskAction -Execute 'shutdown.exe' -Argument '-f -r -t 30'
$trigger = @(
	$(New-ScheduledTaskTrigger -At 5AM -Daily),
	$(New-ScheduledTaskTrigger -At 8PM -Daily)
)
$settings = New-ScheduledTaskSettingsSet -WakeToRun -RunOnlyIfIdle -IdleDuration 05:00:00 -IdleWaitTimeout 06:00:00 -ExecutionTimeLimit (New-TimeSpan -Hours 1)
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "Reboottwiceaday" -Description "Reboot the computer twice a day to avoid unexpected reboots" -RunLevel Highest -User "NT AUTHORITY\SYSTEM" -Force -Settings $settings


if ($externalip -eq $langleyip) {
	$campus = 'Langley'
}
elseif ($externalip -eq $abbyip) {
	$campus = 'Abbotsford'
}
else {
	$campus = 'OffSite'
}

#Get-CampusByIP
# Typing Trainer
if ($campus -eq 'Langley') {
	Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/fireball8931/AOLCCApps/master/Install-HPPrinter.ps1'))
}
if ($campus -eq 'Abbotsford') {
	Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/fireball8931/AOLCCApps/master/Install-AbbotsfordLexmark.ps1'))
}
if ($campus -ne 'OffSite') {
	Write-Host "This computer is at the $cloudloc campus"
	#Set Network to private
	$net = Get-NetConnectionProfile
	try {
		Set-NetConnectionProfile -Name $net.Name -NetworkCategory Private
	}
	catch {
		exit 0
	}
	#Install new printer
	Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/fireball8931/AOLCCApps/master/Install-AOLPrinter.ps1'))

	#Update Typing Trainer
	Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://aolccbc.com/downloads/ChocolateyInstall.ps1'))

	#download the client installer to C:\fogtemp\fog.msi
	Invoke-WebRequest -URI "http://fogserver./fog/client/download.php?newclient" -UseBasicParsing -OutFile 'C:\scriptfiles\fog.msi'
	#run the installer with msiexec and pass the command line args of /quiet /qn /norestart
	Start-Process -FilePath msiexec -ArgumentList @('/i','C:\fogtemp\fog.msi','/quiet','/qn','/norestart') -NoNewWindow -Wait;

};

if ((Test-Path -LiteralPath "c:\Program Files (x86)\Google\Chrome\Application\chrome.exe") -eq $false) {
	if ((Test-Path -LiteralPath "c:\Program Files (x86)\Google\Chrome\Application\chrome.exe") -eq $true) {
		New-Item -ItemType SymbolicLink -Path "c:\Program Files (x86)\Google\Chrome\Application" -Target "c:\Program Files\Google\Chrome\Application"
	}
}

#Manage Software
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/fireball8931/AOLCCApps/master/Manage-Software.ps1'))

#Set GPO like settings
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/fireball8931/AOLCCApps/master/Set-GPOLikeThings.ps1'))
