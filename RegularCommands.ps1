#Requires -RunAsAdministrator
#global variables
$externalip = (Invoke-WebRequest -Uri "http://ifconfig.me/ip" -UseBasicParsing).Content
$langleyip = '66.183.1.50'
$abbyip = '66.183.152.124'


#Actual Commands File
#check disk size
$env:HOMEDRIVE.Substring(0,1) = 
if ((Get-Volume -DriveLetter $env:HOMEDRIVE.Substring(0,1)).SizeRemaining / (1e+9) -lt "1"){
Write-Host Adjusting Volumes
# Variable specifying the drive you want to extend
#$env:HOMEDRIVE.Substring(0,1) = "C"
# Script to get the partition sizes and then resize the volume
$size = (Get-PartitionSupportedSize -DriveLetter $env:HOMEDRIVE.Substring(0,1))
Resize-Partition -DriveLetter $env:HOMEDRIVE.Substring(0,1) -Size $size.SizeMax
}

#Schedule a twice daily reboot
$action = New-ScheduledTaskAction -Execute 'shutdown.exe' -Argument '-f -r -t 30'
$trigger = @(
	$(New-ScheduledTaskTrigger -At 5AM -Daily),
	$(New-ScheduledTaskTrigger -At 8PM -Daily)
)
$settings = New-ScheduledTaskSettingsSet -WakeToRun -RunOnlyIfIdle -IdleDuration 05:00:00 -IdleWaitTimeout 06:00:00 -ExecutionTimeLimit (New-TimeSpan -Hours 1)
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "Reboottwiceaday" -Description "Reboot the computer twice a day to avoid unexpected reboots" -RunLevel Highest -User "NT AUTHORITY\SYSTEM" -Force -Settings $settings


if ($externalip -eq $langleyip) {
	$campus = 'Langley'
}
elseif ($externalip -eq $abbyip) {
	$campus = 'Abbotsford'
}
else {
	$campus = 'OffSite'
}


if ($campus -eq 'Langley') {
#	Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/fireball8931/AOLCCApps/master/Install-HPPrinter.ps1'))
}
if ($campus -eq 'Abbotsford') {
#	Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/fireball8931/AOLCCApps/master/Install-AbbotsfordLexmark.ps1'))
}
if ($campus -ne 'OffSite') {
	Write-Host "This computer is at the $cloudloc campus"
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
	Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

	#Update Typing Trainer
	$github = 'https://raw.githubusercontent.com/fireball8931/AOLCCApps/master/Typing'
	$externalip = (Invoke-WebRequest -Uri 'http://ifconfig.me/ip' -UseBasicParsing).Content
	$langleyip = '66.183.1.50'
	$abbyip = '66.183.152.124'

	if ($externalip -eq $langleyip) {$campus = 'Langley'}
	elseif ($externalip -eq $abbyip) {$campus = 'Abbotsford'}
	else {$campus = 'OffSite'}

	$cloudloc = $github + '/' + $campus + '/'

	$scriptingdir = 'c:\scriptfiles'
	$connectpath = $scriptingdir + '\connect.bat'
	$typingbatdest = $scriptingdir + '\typingtrainer.bat'
	$typingbatsrc = $cloudloc + 'typingtrainer.bat'
	$typingtrainerfolder = 'C:\Program Files (x86)\TypingTrainer'
	$batchsource = $cloudloc + 'connect.bat'
	$databasesrc = $cloudloc + 'database.txt'

	if ((Test-Path -Path $scriptingdir) -eq $false) {
    	New-Item -Path $scriptingdir -Type Directory
	}
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

if ((Test-Path -LiteralPath "c:\Program Files (x86)\Google\Chrome\Application\chrome.exe") -eq $false) {
	if ((Test-Path -LiteralPath "c:\Program Files (x86)\Google\Chrome\Application\chrome.exe") -eq $true) {
		New-Item -ItemType SymbolicLink -Path "c:\Program Files (x86)\Google\Chrome\Application" -Target "c:\Program Files\Google\Chrome\Application"
	}
}

#Manage Software
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/fireball8931/AOLCCApps/master/Manage-Software.ps1'))

#Set GPO like settings
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/fireball8931/AOLCCApps/master/Set-GPOLikeThings.ps1'))

# SIG # Begin signature block
# MIIWgAYJKoZIhvcNAQcCoIIWcTCCFm0CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU1vAKMmznXOdN4YcKylVaxBj1
# u/qgghDaMIIDWjCCAkKgAwIBAgIQVE1UkhnbkL1Em0JU5EuTajANBgkqhkiG9w0B
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
# D1eO3jCCBq4wggSWoAMCAQICEAc2N7ckVHzYR6z9KGYqXlswDQYJKoZIhvcNAQEL
# BQAwYjELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UE
# CxMQd3d3LmRpZ2ljZXJ0LmNvbTEhMB8GA1UEAxMYRGlnaUNlcnQgVHJ1c3RlZCBS
# b290IEc0MB4XDTIyMDMyMzAwMDAwMFoXDTM3MDMyMjIzNTk1OVowYzELMAkGA1UE
# BhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMTswOQYDVQQDEzJEaWdpQ2Vy
# dCBUcnVzdGVkIEc0IFJTQTQwOTYgU0hBMjU2IFRpbWVTdGFtcGluZyBDQTCCAiIw
# DQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAMaGNQZJs8E9cklRVcclA8TykTep
# l1Gh1tKD0Z5Mom2gsMyD+Vr2EaFEFUJfpIjzaPp985yJC3+dH54PMx9QEwsmc5Zt
# +FeoAn39Q7SE2hHxc7Gz7iuAhIoiGN/r2j3EF3+rGSs+QtxnjupRPfDWVtTnKC3r
# 07G1decfBmWNlCnT2exp39mQh0YAe9tEQYncfGpXevA3eZ9drMvohGS0UvJ2R/dh
# gxndX7RUCyFobjchu0CsX7LeSn3O9TkSZ+8OpWNs5KbFHc02DVzV5huowWR0QKfA
# csW6Th+xtVhNef7Xj3OTrCw54qVI1vCwMROpVymWJy71h6aPTnYVVSZwmCZ/oBpH
# IEPjQ2OAe3VuJyWQmDo4EbP29p7mO1vsgd4iFNmCKseSv6De4z6ic/rnH1pslPJS
# lRErWHRAKKtzQ87fSqEcazjFKfPKqpZzQmiftkaznTqj1QPgv/CiPMpC3BhIfxQ0
# z9JMq++bPf4OuGQq+nUoJEHtQr8FnGZJUlD0UfM2SU2LINIsVzV5K6jzRWC8I41Y
# 99xh3pP+OcD5sjClTNfpmEpYPtMDiP6zj9NeS3YSUZPJjAw7W4oiqMEmCPkUEBID
# fV8ju2TjY+Cm4T72wnSyPx4JduyrXUZ14mCjWAkBKAAOhFTuzuldyF4wEr1GnrXT
# drnSDmuZDNIztM2xAgMBAAGjggFdMIIBWTASBgNVHRMBAf8ECDAGAQH/AgEAMB0G
# A1UdDgQWBBS6FtltTYUvcyl2mi91jGogj57IbzAfBgNVHSMEGDAWgBTs1+OC0nFd
# ZEzfLmc/57qYrhwPTzAOBgNVHQ8BAf8EBAMCAYYwEwYDVR0lBAwwCgYIKwYBBQUH
# AwgwdwYIKwYBBQUHAQEEazBpMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdp
# Y2VydC5jb20wQQYIKwYBBQUHMAKGNWh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNv
# bS9EaWdpQ2VydFRydXN0ZWRSb290RzQuY3J0MEMGA1UdHwQ8MDowOKA2oDSGMmh0
# dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRSb290RzQuY3Js
# MCAGA1UdIAQZMBcwCAYGZ4EMAQQCMAsGCWCGSAGG/WwHATANBgkqhkiG9w0BAQsF
# AAOCAgEAfVmOwJO2b5ipRCIBfmbW2CFC4bAYLhBNE88wU86/GPvHUF3iSyn7cIoN
# qilp/GnBzx0H6T5gyNgL5Vxb122H+oQgJTQxZ822EpZvxFBMYh0MCIKoFr2pVs8V
# c40BIiXOlWk/R3f7cnQU1/+rT4osequFzUNf7WC2qk+RZp4snuCKrOX9jLxkJods
# kr2dfNBwCnzvqLx1T7pa96kQsl3p/yhUifDVinF2ZdrM8HKjI/rAJ4JErpknG6sk
# HibBt94q6/aesXmZgaNWhqsKRcnfxI2g55j7+6adcq/Ex8HBanHZxhOACcS2n82H
# hyS7T6NJuXdmkfFynOlLAlKnN36TU6w7HQhJD5TNOXrd/yVjmScsPT9rp/Fmw0HN
# T7ZAmyEhQNC3EyTN3B14OuSereU0cZLXJmvkOHOrpgFPvT87eK1MrfvElXvtCl8z
# OYdBeHo46Zzh3SP9HSjTx/no8Zhf+yvYfvJGnXUsHicsJttvFXseGYs2uJPU5vIX
# mVnKcPA3v5gA3yAWTyf7YGcWoWa63VXAOimGsJigK+2VQbc61RWYMbRiCQ8KvYHZ
# E/6/pNHzV9m8BPqC3jLfBInwAM1dwvnQI38AC+R2AibZ8GV2QqYphwlHK+Z/GqSF
# D/yYlvZVVCsfgPrA8g4r5db7qS9EFUrnEw4d2zc4GqEr9u3WfPwwggbGMIIErqAD
# AgECAhAKekqInsmZQpAGYzhNhpedMA0GCSqGSIb3DQEBCwUAMGMxCzAJBgNVBAYT
# AlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjE7MDkGA1UEAxMyRGlnaUNlcnQg
# VHJ1c3RlZCBHNCBSU0E0MDk2IFNIQTI1NiBUaW1lU3RhbXBpbmcgQ0EwHhcNMjIw
# MzI5MDAwMDAwWhcNMzMwMzE0MjM1OTU5WjBMMQswCQYDVQQGEwJVUzEXMBUGA1UE
# ChMORGlnaUNlcnQsIEluYy4xJDAiBgNVBAMTG0RpZ2lDZXJ0IFRpbWVzdGFtcCAy
# MDIyIC0gMjCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBALkqliOmXLxf
# 1knwFYIY9DPuzFxs4+AlLtIx5DxArvurxON4XX5cNur1JY1Do4HrOGP5PIhp3jzS
# MFENMQe6Rm7po0tI6IlBfw2y1vmE8Zg+C78KhBJxbKFiJgHTzsNs/aw7ftwqHKm9
# MMYW2Nq867Lxg9GfzQnFuUFqRUIjQVr4YNNlLD5+Xr2Wp/D8sfT0KM9CeR87x5MH
# aGjlRDRSXw9Q3tRZLER0wDJHGVvimC6P0Mo//8ZnzzyTlU6E6XYYmJkRFMUrDKAz
# 200kheiClOEvA+5/hQLJhuHVGBS3BEXz4Di9or16cZjsFef9LuzSmwCKrB2NO4Bo
# /tBZmCbO4O2ufyguwp7gC0vICNEyu4P6IzzZ/9KMu/dDI9/nw1oFYn5wLOUrsj1j
# 6siugSBrQ4nIfl+wGt0ZvZ90QQqvuY4J03ShL7BUdsGQT5TshmH/2xEvkgMwzjC3
# iw9dRLNDHSNQzZHXL537/M2xwafEDsTvQD4ZOgLUMalpoEn5deGb6GjkagyP6+Sx
# IXuGZ1h+fx/oK+QUshbWgaHK2jCQa+5vdcCwNiayCDv/vb5/bBMY38ZtpHlJrYt/
# YYcFaPfUcONCleieu5tLsuK2QT3nr6caKMmtYbCgQRgZTu1Hm2GV7T4LYVrqPnqY
# klHNP8lE54CLKUJy93my3YTqJ+7+fXprAgMBAAGjggGLMIIBhzAOBgNVHQ8BAf8E
# BAMCB4AwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDAgBgNV
# HSAEGTAXMAgGBmeBDAEEAjALBglghkgBhv1sBwEwHwYDVR0jBBgwFoAUuhbZbU2F
# L3MpdpovdYxqII+eyG8wHQYDVR0OBBYEFI1kt4kh/lZYRIRhp+pvHDaP3a8NMFoG
# A1UdHwRTMFEwT6BNoEuGSWh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2Vy
# dFRydXN0ZWRHNFJTQTQwOTZTSEEyNTZUaW1lU3RhbXBpbmdDQS5jcmwwgZAGCCsG
# AQUFBwEBBIGDMIGAMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5j
# b20wWAYIKwYBBQUHMAKGTGh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdp
# Q2VydFRydXN0ZWRHNFJTQTQwOTZTSEEyNTZUaW1lU3RhbXBpbmdDQS5jcnQwDQYJ
# KoZIhvcNAQELBQADggIBAA0tI3Sm0fX46kuZPwHk9gzkrxad2bOMl4IpnENvAS2r
# OLVwEb+EGYs/XeWGT76TOt4qOVo5TtiEWaW8G5iq6Gzv0UhpGThbz4k5HXBw2U7f
# IyJs1d/2WcuhwupMdsqh3KErlribVakaa33R9QIJT4LWpXOIxJiA3+5JlbezzMWn
# 7g7h7x44ip/vEckxSli23zh8y/pc9+RTv24KfH7X3pjVKWWJD6KcwGX0ASJlx+pe
# dKZbNZJQfPQXpodkTz5GiRZjIGvL8nvQNeNKcEiptucdYL0EIhUlcAZyqUQ7aUcR
# 0+7px6A+TxC5MDbk86ppCaiLfmSiZZQR+24y8fW7OK3NwJMR1TJ4Sks3KkzzXNy2
# hcC7cDBVeNaY/lRtf3GpSBp43UZ3Lht6wDOK+EoojBKoc88t+dMj8p4Z4A2UKKDr
# 2xpRoJWCjihrpM6ddt6pc6pIallDrl/q+A8GQp3fBmiW/iqgdFtjZt5rLLh4qk1w
# bfAs8QcVfjW05rUMopml1xVrNQ6F1uAszOAMJLh8UgsemXzvyMjFjFhpr6s94c/M
# fRWuFL+Kcd/Kl7HYR+ocheBFThIcFClYzG/Tf8u+wQ5KbyCcrtlzMlkI5y2SoRoR
# /jKYpl0rl+CL05zMbbUNrkdjOEcXW28T2moQbh9Jt0RbtAgKh1pZBHYRoad3AhMc
# MYIFEDCCBQwCAQEwSzA3MTUwMwYDVQQDDCxBY2FkZW15IG9mIExlYXJuaW5nIE0u
# Um9zcyBDb2RlIFNpZ25pbmcgQ2VydAIQVE1UkhnbkL1Em0JU5EuTajAJBgUrDgMC
# GgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYK
# KwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG
# 9w0BCQQxFgQUWeDnqn+csZVPzQ0cw1yyeTRu+1swDQYJKoZIhvcNAQEBBQAEggEA
# WLi1zKqpOVCOLdoPD9xh4AQLLTRX+pkLXuLLzngYvcBmPJ5d1+9hk91IfxynFJBA
# aDhbGkz5dI0PGWXe9aLnGI/95SrvEri3ScbU93CEh6Gdgt1MIWqq45MnpwGK8lbk
# 1fjtmikVEiRN5tstKVx7Gd7PGtGR7GP7nTjmyMY9HeHsM71NLX2yv1LaL2RyyzCh
# c+/m2gc3snLJkSHiKgfRQZ5hNv6OElRUJhQtdKowMnoxoZk+/yv2JTshFp6fxBxj
# 8XHCmXkOC4FnLn6x8DDGM3piLz8tqtWXYQhlm6icvsLLnPEwP1juJ1WxRXI68RVO
# MfpqrGvbdJW3aSXZNmDnR6GCAyAwggMcBgkqhkiG9w0BCQYxggMNMIIDCQIBATB3
# MGMxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjE7MDkGA1UE
# AxMyRGlnaUNlcnQgVHJ1c3RlZCBHNCBSU0E0MDk2IFNIQTI1NiBUaW1lU3RhbXBp
# bmcgQ0ECEAp6SoieyZlCkAZjOE2Gl50wDQYJYIZIAWUDBAIBBQCgaTAYBgkqhkiG
# 9w0BCQMxCwYJKoZIhvcNAQcBMBwGCSqGSIb3DQEJBTEPFw0yMjA0MDUyMjQxNTha
# MC8GCSqGSIb3DQEJBDEiBCBuBsEC6fWMPHpJAzBSOznxNEziAkquTGap4iGFLU5/
# rjANBgkqhkiG9w0BAQEFAASCAgCr3mD4aA31kcZfzyQpBdWMZxQlNqnRow/ZsPXd
# OdECai+M7YRJbWR2ze96yX+hQRlyUHHijTA7I2U9gN3HrcL4GfQhi2ggO3X2UJo6
# 5ufYnyxljrFUQ/4Z/YnSVA1eMN9L6LSlZ+9IWKqwKmiMHGpEVwGIzGisvBN60pqb
# Ta5Bj591hJma95brHq6NGFBeGbDfo4Bbw2VNzQsdkkH5STwQ86oMaorbiIVWEyqe
# 1Cf48PmM+FUsDBOs4drCFLM19CPZoU09QdOC4O7iMzCZfwJjfjpe+LzAccj8sXgP
# UBC3gdaCc5hReBvOfp+/dBWnuxpp2CSRPzyyzZEnQB41hpHiv/j+q/iysrQ5Pzt3
# moDfprB7iF/26Y8LUA5AhQercCxSfmTDJh4xuLFQrvdkWmcXpud9TiYKTqjEfnge
# tBgMXOaOlBRwibD5eemnrNPUwWQPcyfFGLFEUtlC1F8arJz6ZNyOAgGy/Q1av2/3
# HDJyhOGme0FUaTJkMReUoI3GUaYOG4yyb9FvFa/I8Sb/y6F/UOlPS2+aoJQKbFID
# WrVoINB83FsI0yw8Zbe9ygIAuzkVIZLgTUhtKGhx+FCWbO6UTH9X/UgJ8j+czKCS
# f9YjIDqQyvVFNkwxkLC7npnvy+7nvz3OtakGRffx47AN/6eMvLoOay1cdhE9Vdjm
# b70a9A==
# SIG # End signature block
