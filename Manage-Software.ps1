Get-AppxPackage -Name Microsoft.MicrosoftOfficeHub | Remove-AppxPackage -AllUsers

#Chocolatey
if ($null -eq $ENV:ChocolateyInstall) {
	Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://aolccbc.com/downloads/ChocolateyInstall.ps1'))
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

#Activate Office
cscript "C:\Program Files\Microsoft Office\Office16\ospp.vbs" /act