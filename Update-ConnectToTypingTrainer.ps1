$scriptingdir = 'c:\scriptfiles'
$cloudloc = 'https://aolccbc.blob.core.windows.net/aolcc/typingfiles/'
$connectpath = $scriptingdir + '\connect.bat'
$typingbatdest = $scriptingdir + '\typingtrainer.bat'
$typingbatsrc = $cloudloc + 'typingtrainer.bat'
$typingtrainerfolder = 'C:\Program Files (x86)\TypingTrainer'
$tticonsrc = ${env:ProgramFiles(x86)} + '\ACMEPro2011\ACME.exe'
$ttshortcutname = 'Connect to Typing Trainer.lnk'
$ttshortcutdest = $env:ALLUSERSPROFILE + '\Microsoft\Windows\Start Menu\Programs\' + $ttshortcutname




if ((Test-Path -Path $scriptingdir) -eq $false) {
    New-Item -Path $scriptingdir -Type Directory
}
Set-Location -LiteralPath $scriptingdir -Verbose
Invoke-WebRequest -Uri $batchsource -OutFile $connectpath -Verbose -UseBasicParsing
Remove-Item -Path $typingtrainerfolder\database.txt -Force
Invoke-WebRequest -Uri $databasesrc -OutFile $typingtrainerfolder\database.txt -Verbose -UseBasicParsing
Invoke-WebRequest -Uri $typingbatsrc -OutFile $typingbatdest -Verbose -UseBasicParsing
Set-Shortcut -SourceExe $typingbatdest -DestinationPath $ttshortcutdest -IconSrc $tticonsrc