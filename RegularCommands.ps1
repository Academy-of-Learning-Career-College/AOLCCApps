# Self-elevate the script if required
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
	if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
	 $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
	 Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
	 Exit
	}
   }
   
   # Remainder of script here

function New-WifiProfile {

   param(
    [string]$SSID,
    [string]$PSK
)
$guid = New-Guid
$HexArray = $ssid.ToCharArray() | foreach-object { [System.String]::Format("{0:X}", [System.Convert]::ToUInt32($_)) }
$HexSSID = $HexArray -join ""
@"
<?xml version="1.0"?>
<WLANProfile xmlns="http://www.microsoft.com/networking/WLAN/profile/v1">
    <name>$($SSID)</name>
    <SSIDConfig>
        <SSID>
            <hex>$($HexSSID)</hex>
            <name>$($SSID)</name>
        </SSID>
    </SSIDConfig>
    <connectionType>ESS</connectionType>
    <connectionMode>auto</connectionMode>
    <MSM>
        <security>
            <authEncryption>
                <authentication>WPA2PSK</authentication>
                <encryption>AES</encryption>
                <useOneX>false</useOneX>
            </authEncryption>
            <sharedKey>
                <keyType>passPhrase</keyType>
                <protected>false</protected>
                <keyMaterial>$($PSK)</keyMaterial>
            </sharedKey>
        </security>
    </MSM>
    <MacRandomization xmlns="http://www.microsoft.com/networking/WLAN/profile/v3">
        <enableRandomization>false</enableRandomization>
        <randomizationSeed>1451755948</randomizationSeed>
    </MacRandomization>
</WLANProfile>
"@ | out-file "$($ENV:TEMP)\$guid.SSID"
 
netsh wlan add profile filename="$($ENV:TEMP)\$guid.SSID" user=all
 
remove-item "$($ENV:TEMP)\$guid.SSID" -Force
}
#connectoabbotsfordwifi
try {
	Write-Host Connecting to Wifi
New-WifiProfile -SSID "STAFF24g" -PSK "aolcc0404"
}
catch {
	Write-Host No Wifi card installed, skipping
}
#global variables
$scriptingdir = $env:systemdrive + "\scriptfiles"
$timestamp = Get-Date -Format "ddMMyyyyHHmm"
try {
if ((Test-Path -Path $scriptingdir) -eq $false) {
	New-Item -Path $scriptingdir -Type Directory -Force
	$logfile = $scriptingdir + "\RegularCommands." + $timestamp + ".log"	
}
}
	catch {
	$logfile = $env:SystemDrive + "\RegularCommands." + $timestamp + ".log"
	$scriptingdir = $env:TEMP
	}
#Set our log file
Start-Transcript -Path $logfile -Append -Verbose



$externalip = (Invoke-WebRequest -Uri "http://ifconfig.me/ip" -UseBasicParsing).Content
$langleyip = '66.183.1.50'
$abbyip = '66.183.152.124'
try {
if ($externalip -eq $langleyip) {$campus = 'Langley'}
elseif ($externalip -eq $abbyip) {$campus = 'Abbotsford'}
else {$campus = 'OffSite'}
Write-Host This computer is located at the $campus campus
}
catch {
	Write-host This computer is not connected to the internet
}

$githubroot = 'https://raw.githubusercontent.com/fireball8931/AOLCCApps/master/'


#Actual Commands File
#check disk size

try {
	if ((Get-Volume -DriveLetter $env:HOMEDRIVE.Substring(0,1)).SizeRemaining / (1e+9) -lt "1"){
	Write-Host Adjusting Volumes
	$size = (Get-PartitionSupportedSize -DriveLetter $env:HOMEDRIVE.Substring(0,1))
	Resize-Partition -DriveLetter $env:HOMEDRIVE.Substring(0,1) -Size $size.SizeMax
		}
	}
	catch {
		Write-Host No need to extend the drive
	}

# if ($campus -eq 'Langley') { }
# if ($campus -eq 'Abbotsford') { }

if ($campus -ne 'OffSite') {
	#Set Network to private
	$net = Get-NetConnectionProfile
	try {Set-NetConnectionProfile -Name $net.Name -NetworkCategory Private}
	catch {exit 0}
	#Install new printer
	
	Invoke-Expression ((New-Object System.Net.WebClient).DownloadString("$githubroot/Install-AOLPrinter.ps1"))

	#Install Chocolatey
	Invoke-Expression ((New-Object System.Net.WebClient).DownloadString("$githubroot/ChocolateyInstall.ps1"))

	#Update Typing Trainer
	# Set our variables
	$github = $githubroot + 'Typing'
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
	Invoke-WebRequest -URI "http://fogserver./fog/client/download.php?newclient" -UseBasicParsing -OutFile 'C:\scriptfiles\fog.msi'
	#run the installer with msiexec and pass the command line args of /quiet /qn /norestart
	Start-Process -FilePath msiexec -ArgumentList @('/i','C:\fogtemp\fog.msi','/quiet','/qn','/norestart') -NoNewWindow -Wait;

};

#fix chrome shortcuts
if ((Test-Path -LiteralPath "c:\Program Files (x86)\Google\Chrome\Application\chrome.exe") -eq $false) {
	if ((Test-Path -LiteralPath "c:\Program Files (x86)\Google\Chrome\Application\chrome.exe") -eq $true) {
		New-Item -ItemType SymbolicLink -Path "c:\Program Files (x86)\Google\Chrome\Application" -Target "c:\Program Files\Google\Chrome\Application"
	}
}

#Manage Software
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString("$githubroot/Manage-Software.ps1"))

#Set GPO like settings
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString("$githubroot/Set-GPOLikeThings.ps1"))

# SIG # Begin signature block
# MIISSwYJKoZIhvcNAQcCoIISPDCCEjgCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUwnnu2KSUHPee9ox9v4UaBEWA
# sm6ggg2VMIIDWjCCAkKgAwIBAgIQVE1UkhnbkL1Em0JU5EuTajANBgkqhkiG9w0B
# AQsFADA3MTUwMwYDVQQDDCxBY2FkZW15IG9mIExlYXJuaW5nIE0uUm9zcyBDb2Rl
# IFNpZ25pbmcgQ2VydDAeFw0yMjAyMTExNzU0MTZaFw0yMzAyMTExODE0MTZaMDcx
# NTAzBgNVBAMMLEFjYWRlbXkgb2YgTGVhcm5pbmcgTS5Sb3NzIENvZGUgU2lnbmlu
# ZyBDZXJ0MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEApcfn6DQ7aDiw
# 7LPYl5hDCbBVKjluiUq5Gq8LAX9qDzsTHb9/vX44rRIoc8aDppndVBYfYg8JLlsu
# KmeJNqRpQOPabvdwdgZWhesbKr9J/fPZ6QmrN2TKDbV9ldO7Ry4LzRf/WMWZfAGa
# 7LMF3Ze/wZ2jLjd0WWmhhXtki9tl7jq7QUV/6NkQTlRs47puePKQbjgp9nLs98dG
# r0e39GTcUdcp/FK/oga/1Rj6F1ODsNTYUFTfnNg4wYROWOEk+TKKOb3e0rupEsJQ
# 0rQkHlwEosPGzP1GoHHTxxYwWp7/+Mmdje3uhwsqlC5OcUHlx2DpBWpD+jRmL/5s
# MDYrd5A3AQIDAQABo2IwYDAOBgNVHQ8BAf8EBAMCB4AwEwYDVR0lBAwwCgYIKwYB
# BQUHAwMwGgYDVR0RBBMwEYIPd3d3LmFvbGNjYmMuY29tMB0GA1UdDgQWBBRzEJzH
# I91hN73Npa4jVyQA7zN3UjANBgkqhkiG9w0BAQsFAAOCAQEAMkXrv9CmUnsTXyV4
# SlWss7N97lgJq2tlm9hON2kE0ej+9TD8I3dvwFZ3OCkh4LmuWoZGMv++KE1jQLDR
# SDMdbZyIUNdBMIeMwU242VsKKP7l8vG6YYPaQ8jv8bWrthABeoQ48USj4EY3YFLC
# jqRWchuPtCCiSVBIv28H7X8sUJAI/3nrHO2a2s74BI181LIhI6ovvndA3ZsRB/0t
# 2GVyt5LPqNfSl+G1NPkHMGJZmIwyIUBfITvPSEqHCeDhZJoh3vjemJZINwaFjDOk
# iaApO33MoXK4hdpcZJe8WvzveR3TQGFRdMjJhT8ysN+hqDXwjArPPonKoGHshNa+
# D1eO3jCCBP4wggPmoAMCAQICEA1CSuC+Ooj/YEAhzhQA8N0wDQYJKoZIhvcNAQEL
# BQAwcjELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UE
# CxMQd3d3LmRpZ2ljZXJ0LmNvbTExMC8GA1UEAxMoRGlnaUNlcnQgU0hBMiBBc3N1
# cmVkIElEIFRpbWVzdGFtcGluZyBDQTAeFw0yMTAxMDEwMDAwMDBaFw0zMTAxMDYw
# MDAwMDBaMEgxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjEg
# MB4GA1UEAxMXRGlnaUNlcnQgVGltZXN0YW1wIDIwMjEwggEiMA0GCSqGSIb3DQEB
# AQUAA4IBDwAwggEKAoIBAQDC5mGEZ8WK9Q0IpEXKY2tR1zoRQr0KdXVNlLQMULUm
# EP4dyG+RawyW5xpcSO9E5b+bYc0VkWJauP9nC5xj/TZqgfop+N0rcIXeAhjzeG28
# ffnHbQk9vmp2h+mKvfiEXR52yeTGdnY6U9HR01o2j8aj4S8bOrdh1nPsTm0zinxd
# RS1LsVDmQTo3VobckyON91Al6GTm3dOPL1e1hyDrDo4s1SPa9E14RuMDgzEpSlwM
# MYpKjIjF9zBa+RSvFV9sQ0kJ/SYjU/aNY+gaq1uxHTDCm2mCtNv8VlS8H6GHq756
# WwogL0sJyZWnjbL61mOLTqVyHO6fegFz+BnW/g1JhL0BAgMBAAGjggG4MIIBtDAO
# BgNVHQ8BAf8EBAMCB4AwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEF
# BQcDCDBBBgNVHSAEOjA4MDYGCWCGSAGG/WwHATApMCcGCCsGAQUFBwIBFhtodHRw
# Oi8vd3d3LmRpZ2ljZXJ0LmNvbS9DUFMwHwYDVR0jBBgwFoAU9LbhIB3+Ka7S5GGl
# sqIlssgXNW4wHQYDVR0OBBYEFDZEho6kurBmvrwoLR1ENt3janq8MHEGA1UdHwRq
# MGgwMqAwoC6GLGh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9zaGEyLWFzc3VyZWQt
# dHMuY3JsMDKgMKAuhixodHRwOi8vY3JsNC5kaWdpY2VydC5jb20vc2hhMi1hc3N1
# cmVkLXRzLmNybDCBhQYIKwYBBQUHAQEEeTB3MCQGCCsGAQUFBzABhhhodHRwOi8v
# b2NzcC5kaWdpY2VydC5jb20wTwYIKwYBBQUHMAKGQ2h0dHA6Ly9jYWNlcnRzLmRp
# Z2ljZXJ0LmNvbS9EaWdpQ2VydFNIQTJBc3N1cmVkSURUaW1lc3RhbXBpbmdDQS5j
# cnQwDQYJKoZIhvcNAQELBQADggEBAEgc3LXpmiO85xrnIA6OZ0b9QnJRdAojR6Or
# ktIlxHBZvhSg5SeBpU0UFRkHefDRBMOG2Tu9/kQCZk3taaQP9rhwz2Lo9VFKeHk2
# eie38+dSn5On7UOee+e03UEiifuHokYDTvz0/rdkd2NfI1Jpg4L6GlPtkMyNoRdz
# DfTzZTlwS/Oc1np72gy8PTLQG8v1Yfx1CAB2vIEO+MDhXM/EEXLnG2RJ2CKadRVC
# 9S0yOIHa9GCiurRS+1zgYSQlT7LfySmoc0NR2r1j1h9bm/cuG08THfdKDXF+l7f0
# P4TrweOjSaH6zqe/Vs+6WXZhiV9+p7SOZ3j5NpjhyyjaW4emii8wggUxMIIEGaAD
# AgECAhAKoSXW1jIbfkHkBdo2l8IVMA0GCSqGSIb3DQEBCwUAMGUxCzAJBgNVBAYT
# AlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2Vy
# dC5jb20xJDAiBgNVBAMTG0RpZ2lDZXJ0IEFzc3VyZWQgSUQgUm9vdCBDQTAeFw0x
# NjAxMDcxMjAwMDBaFw0zMTAxMDcxMjAwMDBaMHIxCzAJBgNVBAYTAlVTMRUwEwYD
# VQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xMTAv
# BgNVBAMTKERpZ2lDZXJ0IFNIQTIgQXNzdXJlZCBJRCBUaW1lc3RhbXBpbmcgQ0Ew
# ggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC90DLuS82Pf92puoKZxTlU
# KFe2I0rEDgdFM1EQfdD5fU1ofue2oPSNs4jkl79jIZCYvxO8V9PD4X4I1moUADj3
# Lh477sym9jJZ/l9lP+Cb6+NGRwYaVX4LJ37AovWg4N4iPw7/fpX786O6Ij4YrBHk
# 8JkDbTuFfAnT7l3ImgtU46gJcWvgzyIQD3XPcXJOCq3fQDpct1HhoXkUxk0kIzBd
# vOw8YGqsLwfM/fDqR9mIUF79Zm5WYScpiYRR5oLnRlD9lCosp+R1PrqYD4R/nzEU
# 1q3V8mTLex4F0IQZchfxFwbvPc3WTe8GQv2iUypPhR3EHTyvz9qsEPXdrKzpVv+T
# AgMBAAGjggHOMIIByjAdBgNVHQ4EFgQU9LbhIB3+Ka7S5GGlsqIlssgXNW4wHwYD
# VR0jBBgwFoAUReuir/SSy4IxLVGLp6chnfNtyA8wEgYDVR0TAQH/BAgwBgEB/wIB
# ADAOBgNVHQ8BAf8EBAMCAYYwEwYDVR0lBAwwCgYIKwYBBQUHAwgweQYIKwYBBQUH
# AQEEbTBrMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wQwYI
# KwYBBQUHMAKGN2h0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFz
# c3VyZWRJRFJvb3RDQS5jcnQwgYEGA1UdHwR6MHgwOqA4oDaGNGh0dHA6Ly9jcmw0
# LmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcmwwOqA4oDaG
# NGh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RD
# QS5jcmwwUAYDVR0gBEkwRzA4BgpghkgBhv1sAAIEMCowKAYIKwYBBQUHAgEWHGh0
# dHBzOi8vd3d3LmRpZ2ljZXJ0LmNvbS9DUFMwCwYJYIZIAYb9bAcBMA0GCSqGSIb3
# DQEBCwUAA4IBAQBxlRLpUYdWac3v3dp8qmN6s3jPBjdAhO9LhL/KzwMC/cWnww4g
# Qiyvd/MrHwwhWiq3BTQdaq6Z+CeiZr8JqmDfdqQ6kw/4stHYfBli6F6CJR7Euhx7
# LCHi1lssFDVDBGiy23UC4HLHmNY8ZOUfSBAYX4k4YU1iRiSHY4yRUiyvKYnleB/W
# CxSlgNcSR3CzddWThZN+tpJn+1Nhiaj1a5bA9FhpDXzIAbG5KHW3mWOFIoxhynmU
# fln8jA/jb7UBJrZspe6HUSHkWGCbugwtK22ixH67xCUrRwIIfEmuE7bhfEJCKMYY
# Vs9BNLZmXbZ0e/VWMyIvIjayS6JKldj1po5SMYIEIDCCBBwCAQEwSzA3MTUwMwYD
# VQQDDCxBY2FkZW15IG9mIExlYXJuaW5nIE0uUm9zcyBDb2RlIFNpZ25pbmcgQ2Vy
# dAIQVE1UkhnbkL1Em0JU5EuTajAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEK
# MAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3
# AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUnkMH2po+oJnwLZNr
# CHgIauS30n4wDQYJKoZIhvcNAQEBBQAEggEAZIh9ZC84fjJYjR3xrxg/PKHgEB0P
# MmSu9wxMOqIOvIHLZ51IGw+Ukpf43Hwzj14XcWyHEzwh2Oe2RX+eQCOPSIod2GMs
# 0ZNHfqVrZ3+TinOgkzJlhit+OsJDscivyUtIHbtfZKMTRoaumPH5aIjTTsJGS/LS
# awNbc6dEdD4QWkdbLilI0bbleU7m8o7X6Fq2V0dVDP8Paf121y+KWofhs6JSE2+8
# 6aYTfutLTes5O/zX6+lVDDd27ZmKRAbRm3T/rLfBFIX9lR0iuMPBHGA0FTN00QN5
# ScIoM7b+vciMsYcA3RSLNrb8PMDr2W28sgV5JiPeYKeAAt9NHJYqzTFyMqGCAjAw
# ggIsBgkqhkiG9w0BCQYxggIdMIICGQIBATCBhjByMQswCQYDVQQGEwJVUzEVMBMG
# A1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMTEw
# LwYDVQQDEyhEaWdpQ2VydCBTSEEyIEFzc3VyZWQgSUQgVGltZXN0YW1waW5nIENB
# AhANQkrgvjqI/2BAIc4UAPDdMA0GCWCGSAFlAwQCAQUAoGkwGAYJKoZIhvcNAQkD
# MQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMjIwMzI4MjIwMjU1WjAvBgkq
# hkiG9w0BCQQxIgQg+nuMSZgu5Q5CHc21h7Pw/6tZOq8UlVn2H0S5Mib2jUIwDQYJ
# KoZIhvcNAQEBBQAEggEAawueWoGTa+S50z1Ayi519aegsZi1t52C3ekev/Kc7IZj
# jMKBEaQMXq/7k4+KYDvF/lu3wZDOFLj1cahx+yKwaPGvqAqhGtHyXb4oV7EuFiGI
# LlpB1YqIZ/f9ZKXEVTONyqAeWV2QdTvjGVkIBgQhh+F48dvGmjdP0AIgvFaD4F48
# bmncpQ7N0ueKDR2cKRliZJv49sKmoODfhJVmsLttjNm9hJxX40UbAFN6CjkORfM6
# qmgz2SQZe0vYKYbBuABl1G0zvQv0QHx+Wk3SF9p+eXd0hd6pP2iTYeyHkp19xaRA
# JoiyuNpbNHpPVZ0FobWmHH5DvoWF/8TeUPJsNNby/A==
# SIG # End signature block
