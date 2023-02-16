#VERSIONS TO CHECK FOR
$acme = '215.4'



#Get-AppxPackage -Name Microsoft.MicrosoftOfficeHub -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue

#Chocolatey
if ($null -eq $ENV:ChocolateyInstall) {
	Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/fireball8931/AOLCCApps/master/ChocolateyInstall.ps1'))
}
$chocosources= choco source
$source = Select-String -InputObject $chocosources -Pattern "aolcc_hosted2"
if ([string]::IsNullOrEmpty($source)){
Write-Host 'AOLCC Source not set, installing AOLCC source'
choco source add --source='https://choco.aolccbc.com/' --name='aolcc_hosted2'
}
$source = Select-String -InputObject $chocosources -Pattern "choco-proxy"
if ([string]::IsNullOrEmpty($source)){
Write-Host 'AOLCC proxy Source not set, installing AOLCC source'
choco source add --source='https://nexus.aolccbc.com/repository/choco-proxy/' --name='choco-proxy'
}
#install K-LiteCodecPack-Standard, Java runtime 8, ACME, and latest version of respondus lockdown browser
choco upgrade -y k-litecodecpack-standard jre8 acme respondusldb fog

if ((Get-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\ACME" | Select-Object version).version -lt $acme) {
	choco install -y --force acme
}

#Activate Office
cscript "C:\Program Files\Microsoft Office\Office16\ospp.vbs" /inpkey:B6KBT-DN948-TCMXK-JQH4R-3DC63
cscript "C:\Program Files\Microsoft Office\Office16\ospp.vbs" /act

