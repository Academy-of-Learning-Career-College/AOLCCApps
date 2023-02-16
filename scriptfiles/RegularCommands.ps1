#global variables
$global:scriptingdir = 'c:\scriptfiles'
$global:cloudloc = 'https://aolccbc.blob.core.windows.net/aolcc/typingfiles/'
$global:connectpath = $global:scriptingdir + '\connect.bat'
$global:typingbatdest = $global:scriptingdir + '\typingtrainer.bat'
$global:typingbatsrc = $global:cloudloc + 'typingtrainer.bat'
$global:typingtrainerfolder = 'C:\Program Files (x86)\TypingTrainer'
$global:tticonsrc = ${env:ProgramFiles(x86)} + '\ACMEPro2011\ACME.exe'
$global:ttshortcutname = 'Connect to Typing Trainer.lnk'
$global:ttshortcutdest = $env:ALLUSERSPROFILE + '\Microsoft\Windows\Start Menu\Programs\' + $global:ttshortcutname


#functions

function Set-Shortcut {
	param([string]$SourceExe,[string]$ArgumentsToSourceExe,[string]$DestinationPath,[string]$IconSrc)
	$WshShell = New-Object -ComObject WScript.Shell
	$Shortcut = $WshShell.CreateShortcut($DestinationPath)
	$Shortcut.TargetPath = $SourceExe
	$Shortcut.Arguments = $ArgumentsToSourceExe
    $Shortcut.IconLocation = $IconSrc
    $Shortcut.WindowStyle = 7
	$Shortcut.Save()
}


function Get-CampusByIP {
	$externalip = (Invoke-WebRequest -Uri "http://ifconfig.me/ip" -UseBasicParsing).Content
	$langleyip = '66.183.1.50'
	$abbyip = '66.183.152.124'

	if ($externalip -eq $langleyip) {
		$global:campus = 'Langley'
	}
	elseif ($externalip -eq $abbyip) {
		$global:campus = 'Abbotsford'
	}
	else {
		$global:campus = 'OffSite'
	}

}

function Update-ConnectToTypingTrainer {
	if ((Test-Path -Path $global:scriptingdir) -eq $false) {
		New-Item -Path $global:scriptingdir -Type Directory
	}
	Set-Location -LiteralPath $global:scriptingdir -Verbose
	Invoke-WebRequest -Uri $global:batchsource -OutFile $global:connectpath -Verbose -UseBasicParsing
	Remove-Item -Path $global:typingtrainerfolder\database.txt -Force
	Invoke-WebRequest -Uri $global:databasesrc -OutFile $global:typingtrainerfolder\database.txt -Verbose -UseBasicParsing
	Invoke-WebRequest -Uri $global:typingbatsrc -OutFile $global:typingbatdest -Verbose -UseBasicParsing
    Set-Shortcut -SourceExe $global:typingbatdest -DestinationPath $global:ttshortcutdest -IconSrc $global:tticonsrc

};




#Actual Commands File
Write-Host Setting Registry Values

if ((Test-Path -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU') -ne $true) { New-Item 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' -Force -ea SilentlyContinue };
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' -Name 'NoAutoRebootWithLoggedOnUsers' -Value 1 -PropertyType DWord -Force -ea SilentlyContinue;

if ((Test-Path -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive') -ne $true) { New-Item 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive' -Force -ea SilentlyContinue };
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive' -Name 'DisableFileSync' -Value 0 -PropertyType DWord -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive' -Name 'DisableFileSyncNGSC' -Value 0 -PropertyType DWord -Force -ea SilentlyContinue;

if ((Test-Path -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell') -ne $true) { New-Item 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell' -Force -ea SilentlyContinue };
if ((Test-Path -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging') -ne $true) {
	New-Item 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging' -Force -ea SilentlyContinue
};
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell' -Name 'EnableScripts' -Value 1 -PropertyType DWord -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell' -Name 'ExecutionPolicy' -Value 'Unrestricted' -PropertyType String -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging' -Name 'EnableScriptBlockLogging' -Value 1 -PropertyType DWord -Force -ea SilentlyContinue;

if ((Test-Path -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System') -ne $true) {
	New-Item 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Force -ea SilentlyContinue };
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name 'ConsentPromptBehaviorUser' -Value 1 -PropertyType DWord -Force -ea SilentlyContinue;


Add-LocalGroupMember -Group "Remote Desktop Users" -Member "AzureAD\mike@aolccbc.com"
(Get-WmiObject -Class "Win32_TSGeneralSetting" -Namespace root\cimv2\terminalservices -Filter "TerminalName='RDP-tcp'").SetUserAuthenticationRequired(0)

$idlelogoffpath = "c:\scriptfiles\idlelogoff.exe"

if ((Test-Path -LiteralPath $idlelogoffpath) -eq $false) {
	wget -Uri https://www.aolccbc.com/downloads/idlelogoff.exe -OutFile $idlelogoffpath
}

$idleshortcutpath = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\idlelogoff.lnk"
if ((Test-Path -LiteralPath $idleshortcutpath) -eq $false) {

	Set-Shortcut -SourceExe $idlelogoffpath -ArgumentsToSourceExe "14400 restart" -DestinationPath $idleshortcutpath
}

powercfg -h off

$action = New-ScheduledTaskAction -Execute 'shutdown.exe' -Argument '-f -r -t 30'

$trigger = @(
	$(New-ScheduledTaskTrigger -At 5AM -Daily),
	$(New-ScheduledTaskTrigger -At 8PM -Daily)
)

$settings = New-ScheduledTaskSettingsSet -WakeToRun -RunOnlyIfIdle -IdleDuration 05:00:00 -IdleWaitTimeout 06:00:00 -ExecutionTimeLimit (New-TimeSpan -Hours 1)


Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "Reboottwiceaday" -Description "Reboot the computer twice a day to avoid unexpected reboots" -RunLevel Highest -User "NT AUTHORITY\SYSTEM" -Force -Settings $settings


Get-AppxPackage -Name Microsoft.MicrosoftOfficeHub | Remove-AppxPackage -AllUsers

$Lockscreen = 'AOLCC_Wallpaper.jpg'
$LockscreenURI = 'https://aolccbc.blob.core.windows.net/aolcc/AOLCC_Wallpaper_Grey.jpg'
$scriptdir = 'C:\scriptfiles\'
$LockscreenFullPath = $scriptdir + $Lockscreen

if ((Test-Path -Path $LockscreenFullPath) -eq $false) {
	Invoke-WebRequest -Uri $LockscreenURI -OutFile $LockscreenFullPath
}
$strPath3 = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization'

New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows' -Name 'Personalization' -Force
Set-ItemProperty -Path $strPath3 -Name 'LockScreenImage' -Value $LockscreenFullPath

powercfg -SetActive '8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c'
Get-Volume | Optimize-Volume
Write-Host "Configuring PeerCaching..." -ForegroundColor Cyan
Write-Host ""
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config' -Name 'DODownloadMode' -Value '1'

Write-Host "Removing Transparency Effects..." -ForegroundColor Green
Write-Host ""
Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize' -Name 'EnableTransparency' -Value '0'

Write-Host "Modifying WMI Configuration..." -ForegroundColor Green
Write-Host ""
$oWMI = Get-WmiObject -Namespace root -Class __ProviderHostQuotaConfiguration
$oWMI.MemoryPerHost = 768 * 1024 * 1024
$oWMI.MemoryAllHosts = 1536 * 1024 * 1024
$oWMI.put()
Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\Winmgmt -Name 'Group' -Value 'COM Infrastructure'
winmgmt /standalonehost

# Disable New Network Dialog:
Write-Host "Disabling New Network Dialog..." -ForegroundColor Green
Write-Host ""
New-Item -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Network' -Name 'NewNetworkWindowOff' | Out-Null
Write-Host "Disabling IE First Run Wizard..." -ForegroundColor Green
Write-Host ""
New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft' -Name 'Internet Explorer' | Out-Null
New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer' -Name 'Main' | Out-Null
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Main' -Name DisableFirstRunCustomize -PropertyType DWORD -Value '1' | Out-Null

# Disable Hibernate
Write-Host "Disabling Hibernate..." -ForegroundColor Green
Write-Host ""
powercfg -h off

reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowStatusBar" /t REG_DWORD /d "1" /f

reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideFileExt" /t REG_DWORD /d "0" /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v "EnableFirstLogonAnimation" /t REG_DWORD /d "0" /f

reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "LaunchTo" /t REG_DWORD /d "1" /f

reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Thumbnail Cache" /v "Autorun" /t REG_DWORD /d "0" /f
reg add "HKLM\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Thumbnail Cache" /v "Autorun" /t REG_DWORD /d "0" /f


reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\SystemRestore" /v "SystemRestorePointCreationFrequency" /t REG_DWORD /d "0" /f


reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager" /v "ConfirmationCheckBoxDoForAll" /t REG_DWORD /d "1" /f
reg add "HKCU\Software\Microsoft\Clipboard" /v "EnableClipboardHistory" /t REG_DWORD /d "1" /f

reg add "HKCU\Software\Policies\Microsoft\MicrosoftEdge\TabPreloader" /v "AllowPrelaunch" /t REG_DWORD /d "0" /f

reg add "HKCU\Software\Policies\Microsoft\MicrosoftEdge\TabPreloader" /v "AllowTabPreloading" /t REG_DWORD /d "0" /f

if ((Test-Path -Path 'c:\defaultassociations.xml') -eq $false) {
	Invoke-WebRequest -Uri 'https://www.aolccbc.com/downloads/defaultassociations.xml' -OutFile 'c:\defaultassociations.xml'
}
reg add 'HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\System' /v DefaultAssociationsConfiguration /t REG_SZ /d 'c:\defaultassociations.xml' /f


# Typing Trainer
if ($global:campus -eq 'Langley') {
	$global:batchsource = $global:cloudloc + 'langley.bat'
	$global:databasesrc = $global:cloudloc + 'database.txt'
	Update-ConnectToTypingTrainer
}
if ($global:campus -eq 'Abbotsford') {
	$global:batchsource = $global:cloudloc + 'abbotsford.bat'
	$global:databasesrc = $global:cloudloc + 'databaseab.txt'
	Update-ConnectToTypingTrainer
}
if ($global:campus -ne 'OffSite') {
	Write-Host 'This computer is At one of the campuses'
	$net = Get-NetConnectionProfile
	try {
		Set-NetConnectionProfile -Name $net.Name -NetworkCategory Private
	}
	catch {
		exit 0
	}
};

if ((Test-Path -LiteralPath "c:\Program Files (x86)\Google\Chrome\Application\chrome.exe") -eq $false) {
	if ((Test-Path -LiteralPath "c:\Program Files (x86)\Google\Chrome\Application\chrome.exe") -eq $true) {
		New-Item -ItemType SymbolicLink -Path "c:\Program Files (x86)\Google\Chrome\Application" -Target "c:\Program Files\Google\Chrome\Application"
	}
}

#choco apps
if ($null -eq $ENV:ChocolateyInstall) {
	Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}
choco upgrade -y k-litecodecpack-standard jre8 googlechrome

#chrome policies
if ((Test-Path -LiteralPath "HKLM:\SOFTWARE\Policies\Google\Chrome") -ne $true) { New-Item "HKLM:\SOFTWARE\Policies\Google\Chrome" -Force -ea SilentlyContinue };
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Google\Chrome' -Name 'DefaultBrowserSettingEnabled' -Value 0 -PropertyType DWord -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Google\Chrome' -Name 'BookmarkBarEnabled' -Value 1 -PropertyType DWord -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Google\Chrome' -Name 'ManagedBookmarks' -Value '[{"name":"AOLCCBC.COM","url":"https://aolccbc.com/"},{"name":"ATTENDANCE","url":"https://acmeweb.academyoflearning.net/Forms/AttendanceLogin.aspx"},{"name":"Courses/myAOLCC","url":"https://my.aolcc.ca/"}]' -PropertyType String -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Google\Chrome' -Name 'ShowHomeButton' -Value 1 -PropertyType DWord -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Google\Chrome' -Name 'ProfilePickerOnStartupAvailability' -Value 0 -PropertyType DWord -Force -ea SilentlyContinue;

#Remotely

if ((Test-Path -LiteralPath "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Remotely") -eq $false) {
	$RemotelyDLPath = "c:\scriptfiles\Remotely_Install.exe"
	if ((Test-Path -LiteralPath $RemotelyDLPath) -eq $false) {
		Invoke-WebRequest -Uri "https://aolccbc.com/downloads/Remotely_Install-[dd5d].exe" -OutFile $RemotelyDLPath
	}
	Start-Process -FilePath $RemotelyDLPath -ArgumentList '-install -quiet -organizationid "9703dec1-5ba4-493f-baac-7e5dd92caf71" -serverurl "https://support.aolccbc.com" -supportshortcut -devicegroup "Students"' -Wait
}
#Install ACME
$acmeversion = '214.5'
$acmedisplayversion = '2011.' + $acmeversion
$installfile = 'acmepro.2011.setup.v' + $acmeversion + '.exe'
$url = 'https://aolccbc.com/downloads/' + $installfile
$dllocation = 'c:\scriptfiles' + $installfile
$uninstallstring = (Get-ItemProperty -Path 'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\ACME*').UninstallString
if ((Get-ItemProperty -Path 'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\ACME*').DisplayVersion -ne $acmedisplayversion) {
	if ([string]::IsNullOrEmpty($uninstallstring)) {
		Start-Process -FilePath (Get-ItemProperty -Path 'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\ACME*').UninstallString -ArgumentList '/QUIET'
	}
	if ((Test-Path -Path $installfile) -eq $false) {
		wget -Uri $url -OutFile $installfile
	}
	Start-Process -FilePath $dllocation -ArgumentList '/SP- /VERYSILENT /SUPPRESSMSGBOXES /ALLUSERS /FORCECLOSEAPPLICATIONS /NOICONS'
}


#Disable WSD
Set-Service -Name WSDPrintDevice -StartupType Disabled
#Install StudentLexmark
if ($global:campus -eq 'Abbotsford') {
	$studentlexmarkdl = 'c:\scriptfiles\StudentLexmarkPrinter.exe'
	$studentlexmarkuri = 'https://aolccbc.com/downloads/StudentLexmarkPrinter.exe'
	if ((Test-Path -Path $studentlexmarkdl) -eq $false) {
		Invoke-WebRequest -Uri $studentlexmarkuri -OutFile $studentlexmarkdl
	}
	Start-Process 'c:\scriptfiles\StudentLexmarkPrinter.exe' -ArgumentList 'e -y' -Wait
    Start-Process 'C:\scriptfiles\LexmarkPkgInstaller.exe' -Wait
    
	#Get-Printer -Name "Abbotsford S*" | Remove-Printer
	#Add-PrinterPort -Name 192.168.1.233_1 -PrinterHostAddress 192.168.1.233
	#Get-Printer -Name "*Student*" | Set-Printer -PortName 192.168.1.233_1
}

#Removing Staff Printers from student computers
#Check to see if *not* a staff computer

if ((test-path C:\scriptfiles\thisisastaffcomputer) -eq $false) {
    Get-Printer | Select-Object Name, DriverName | Where-Object {$_.DriverName -clike "*Brother*"} | Remove-Printer
}
    if (-not ($global:campus -eq 'Abbotsford')) {
        Write-Host 'Not at Abbotsford'
        exit
    }
Add-PrinterPort -Name 192.168.1.228_1 -PrinterHostAddress 192.168.1.228 -ErrorAction SilentlyContinue
Add-Printer -Name 'Abbotsford Facilitator' -PortName 192.168.1.228_1 -DriverName 'Brother Laser Type2 Class Driver'

Write-Host 'This file was updated on October 19 2021'

