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
Get-CampusByIP
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

#functions
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
		Invoke-WebRequest -Uri $url -OutFile $installfile
	}
	Start-Process -FilePath $dllocation -ArgumentList '/SP- /VERYSILENT /SUPPRESSMSGBOXES /ALLUSERS /FORCECLOSEAPPLICATIONS /NOICONS'
}


Write-Host 'This file was updated on October 18 2021'
