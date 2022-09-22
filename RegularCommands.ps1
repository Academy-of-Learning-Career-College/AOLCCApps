# Begin Code 
#Requires -RunAsAdministrator
#global variables
$externalip = (Invoke-WebRequest -Uri "http://ifconfig.me/ip" -UseBasicParsing).Content
$langleyip = '66.183.1.50'
$abbyip = '66.183.152.124'
$scriptingdir = 'c:\scriptfiles'

#check disk size
if ((Get-Volume -DriveLetter $env:HOMEDRIVE.Substring(0,1)).SizeRemaining / (1e+9) -lt "1"){
	Write-Host Adjusting Volumes
	$size = (Get-PartitionSupportedSize -DriveLetter $env:HOMEDRIVE.Substring(0,1))
	Resize-Partition -DriveLetter $env:HOMEDRIVE.Substring(0,1) -Size $size.SizeMax
}
# Make sure the scripting dir is there
if ((Test-Path -Path $scriptingdir) -eq $false) {
	New-Item -Path $scriptingdir -Type Directory
}

if ($externalip -eq $langleyip) {$campus = 'Langley'}
elseif ($externalip -eq $abbyip) {$campus = 'Abbotsford'}
else {$campus = 'OffSite'}

if ($campus -eq 'Langley') {
# Do Something specific to Langley here

}
if ($campus -eq 'Abbotsford') {
# Do Somthing at the Abbotsford
}
if ($campus -ne 'OffSite') {
	Write-Host "This computer is at the $campus campus"
	#Set Network to private
	$net = Get-NetConnectionProfile
	try {
		Set-NetConnectionProfile -Name $net.Name -NetworkCategory Private
	}
	catch {
		exit 0
	}
	#Install new printer
	Set-ExecutionPolicy RemoteSigned -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/fireball8931/AOLCCApps/master/Install-AOLPrinter.ps1'))
	#Install Chocolatey
	Set-ExecutionPolicy RemoteSigned -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/fireball8931/AOLCCApps/master/ChocolateyInstall.ps1'))

	#Update Typing Trainer
	$github = 'https://raw.githubusercontent.com/fireball8931/AOLCCApps/master/Typing'
	$externalip = (Invoke-WebRequest -Uri 'http://ifconfig.me/ip' -UseBasicParsing).Content
	$langleyip = '66.183.1.50'
	$abbyip = '66.183.152.124'

	$cloudloc = $github + '/' + $campus + '/'

	
	$connectpath = $scriptingdir + '\connect.bat'
	$typingbatdest = $scriptingdir + '\typingtrainer.bat'
	$typingbatsrc = $cloudloc + 'typingtrainer.bat'
	$typingtrainerfolder = 'C:\Program Files (x86)\TypingTrainer'
	$batchsource = $cloudloc + 'connect.bat'
	$databasesrc = $cloudloc + 'database.txt'

	
	Set-Location -LiteralPath $scriptingdir -Verbose
	Invoke-WebRequest -Uri $batchsource -OutFile $connectpath -Verbose -UseBasicParsing
	Remove-Item -Path $typingtrainerfolder\database.txt -Force
	Invoke-WebRequest -Uri $databasesrc -OutFile $typingtrainerfolder\database.txt -Verbose -UseBasicParsing
	Invoke-WebRequest -Uri $typingbatsrc -OutFile $typingbatdest -Verbose -UseBasicParsing

	#download the client installer to C:\fogtemp\fog.msi
	$fogmsi = $scriptingdir + "fog.msi"
	Invoke-WebRequest -URI "http://fogserver./fog/client/download.php?newclient" -UseBasicParsing -OutFile $fogmsi
	#run the installer with msiexec and pass the command line args of /quiet /qn /norestart
	Start-Process -FilePath msiexec -ArgumentList @('/i',$fogmsi,'/quiet','/qn','/norestart') -NoNewWindow -Wait;

};

#Fix Chrome Shortcut issues

$chromex86root = "c:\Program Files (x86)\Google\Chrome\Application"
$chromex64bin = $chromex86root + "\chrome.exe"
$chromex64 = "c:\Program Files\Google\Chrome\Application"

if ((Test-Path -LiteralPath "$chromex64bin") -eq $false) {
	if ((Test-Path -LiteralPath "$chromex64bin") -eq $true) {
		New-Item -ItemType SymbolicLink -Path "$chromex86root" -Target "$chromex64"
	}
}

#Manage Software
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/fireball8931/AOLCCApps/master/Manage-Software.ps1'))

#Set GPO like settings
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/fireball8931/AOLCCApps/master/Set-GPOLikeThings.ps1'))

# End Code
