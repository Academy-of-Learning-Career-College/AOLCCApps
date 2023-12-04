function Send-TeamsMessage {param([string]$log,[string]$message = "No message provided",[string]$myTeamsWebHook = "https://aolccbc.webhook.office.com/webhookb2/1db6062d-7e55-421e-a2d9-d599692916e9@2cba7723-a119-4394-9d02-27aac2d1ed11/IncomingWebhook/e2ff12e2822541a9a5ac021d8767f0a2/ea32a7b2-5faf-4585-b298-fb1559f82dca",[string]$mentionedUser = [PSCustomObject] @{id = "mike@aolccbc.com"; name = "MikeRoss"});if ($message -eq "No message provide"){$message=''};$JSONBody = [PSCustomObject] [Ordered]@{"@type" = "MessageCard";"@context" = "http://schema.org/extensions";"summary" = "Hello from PowerShell!";"text" = "<at>$($mentionedUser.name)</at > $log $message";"mentions" = @($mentionedUser);};$TeamMessageBody = ConvertTo-Json $JSONBody -Depth 100;$parameters = @{"URI" = $myTeamsWebHook;"Method" = 'POST';"Body" = $TeamMessageBody;"ContentType" = 'application/json';};Invoke-RestMethod @parameters}
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



$message = "$ENV:COMPUTERNAME has ACME, office has been activated and lockdown browser should be installed"

Send-TeamsMessage -message $message
