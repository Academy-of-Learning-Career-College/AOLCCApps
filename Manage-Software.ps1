#VERSIONS TO CHECK FOR
$acme = '216.1'

#Get-AppxPackage -Name Microsoft.MicrosoftOfficeHub -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue

#Chocolatey
# @"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
Set-Variable "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
#install K-LiteCodecPack-Standard, Java runtime 8, ACME, and latest version of respondus lockdown browser
choco upgrade -y k-litecodecpack-standard jre8 acme respondusldb fog

if ((Get-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\ACME" | Select-Object version).version -lt $acme) {
	choco install -y --force acme
}

#Activate Office
cscript "C:\Program Files\Microsoft Office\Office16\ospp.vbs" /inpkey:B6KBT-DN948-TCMXK-JQH4R-3DC63
cscript "C:\Program Files\Microsoft Office\Office16\ospp.vbs" /act


