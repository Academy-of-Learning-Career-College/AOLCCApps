$github = 'https://raw.githubusercontent.com/fireball8931/AOLCCApps/master/Typing'
$externalip = (Invoke-WebRequest -Uri "http://ifconfig.me/ip" -UseBasicParsing).Content
$langleyip = '66.183.1.50'
$abbyip = '66.183.152.124'

if ($externalip -eq $langleyip) {$campus = 'Langley'}
elseif ($externalip -eq $abbyip) {$campus = 'Abbotsford'}
else {$campus = 'OffSite'}

$cloudloc = $github + '/' + $campus + '/'

$scriptingdir = 'c:\scriptfiles'
#$cloudloc = 'https://aolccbc.blob.core.windows.net/aolcc/typingfiles/'
$connectpath = $scriptingdir + '\connect.bat'
$typingbatdest = $scriptingdir + '\typingtrainer.bat'
$typingbatsrc = $cloudloc + 'typingtrainer.bat'
$typingtrainerfolder = 'C:\Program Files (x86)\TypingTrainer'
$tticonsrc = ${env:ProgramFiles(x86)} + '\ACMEPro2011\ACME.exe'
$ttshortcutname = 'Connect to Typing Trainer.lnk'
$ttshortcutdest = $env:ALLUSERSPROFILE + '\Microsoft\Windows\Start Menu\Programs\' + $ttshortcutname
$batchsource = $cloudloc + 'connect.bat'



if ((Test-Path -Path $scriptingdir) -eq $false) {
    New-Item -Path $scriptingdir -Type Directory
}
Set-Location -LiteralPath $scriptingdir -Verbose
Invoke-WebRequest -Uri $batchsource -OutFile $connectpath -Verbose -UseBasicParsing
Remove-Item -Path $typingtrainerfolder\database.txt -Force
Invoke-WebRequest -Uri $databasesrc -OutFile $typingtrainerfolder\database.txt -Verbose -UseBasicParsing
Invoke-WebRequest -Uri $typingbatsrc -OutFile $typingbatdest -Verbose -UseBasicParsing
Set-Shortcut -SourceExe $typingbatdest -DestinationPath $ttshortcutdest -IconSrc $tticonsrc