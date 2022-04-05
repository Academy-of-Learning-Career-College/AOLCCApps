Write-Host Setting Registry Values and Adjusting Services

Set-Service -Name WSDPrintDevice -StartupType Disabled
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

# Disable New Network Dialog:
Write-Host "Disabling New Network Dialog..." -ForegroundColor Green
Write-Host ""
New-Item -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Network' -Name 'NewNetworkWindowOff' | Out-Null
Write-Host "Disabling IE First Run Wizard..." -ForegroundColor Green
Write-Host ""
New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft' -Name 'Internet Explorer' | Out-Null
New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer' -Name 'Main' | Out-Null
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Main' -Name DisableFirstRunCustomize -PropertyType DWORD -Value '1' | Out-Null

# Set Default Associations
Invoke-WebRequest -Uri 'https://www.aolccbc.com/downloads/defaultassociations.xml' -OutFile 'c:\defaultassociations.xml'
reg add 'HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\System' /v DefaultAssociationsConfiguration /t REG_SZ /d 'c:\defaultassociations.xml' /f

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


#Set Wallpaper
$Lockscreen = 'AOLCC_Wallpaper.jpg'
$LockscreenURI = 'https://aolccbc.blob.core.windows.net/aolcc/AOLCC_Wallpaper_Grey.jpg'
$scriptdir = 'C:\scriptfiles\'
$LockscreenFullPath = $scriptdir + $Lockscreen

if ((Test-Path -Path $LockscreenFullPath) -eq $false) {
	Invoke-WebRequest -Uri $LockscreenURI -OutFile $LockscreenFullPath
}
$strPath3 = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization'

powercfg -h off

#chrome policies
if ((Test-Path -LiteralPath "HKLM:\SOFTWARE\Policies\Google\Chrome") -ne $true) { New-Item "HKLM:\SOFTWARE\Policies\Google\Chrome" -Force -ea SilentlyContinue };
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Google\Chrome' -Name 'DefaultBrowserSettingEnabled' -Value 0 -PropertyType DWord -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Google\Chrome' -Name 'BookmarkBarEnabled' -Value 1 -PropertyType DWord -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Google\Chrome' -Name 'ManagedBookmarks' -Value '[{"name":"AOLCCBC.COM","url":"https://aolccbc.com/"},{"name":"ATTENDANCE","url":"https://acmeweb.academyoflearning.net/Forms/AttendanceLogin.aspx"},{"name":"Courses/myAOLCC","url":"https://my.aolcc.ca/"}]' -PropertyType String -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Google\Chrome' -Name 'ShowHomeButton' -Value 1 -PropertyType DWord -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Google\Chrome' -Name 'ProfilePickerOnStartupAvailability' -Value 0 -PropertyType DWord -Force -ea SilentlyContinue;


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
# SIG # Begin signature block
# MIIWgAYJKoZIhvcNAQcCoIIWcTCCFm0CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU3boJxe21OlolMKqtffFJ7vSF
# PLGgghDaMIIDWjCCAkKgAwIBAgIQVE1UkhnbkL1Em0JU5EuTajANBgkqhkiG9w0B
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
# 9w0BCQQxFgQUIJH/xt45/noIEazW4WFx1EyaFegwDQYJKoZIhvcNAQEBBQAEggEA
# obLyGDgNOiagEwDFIkFP57ifIdBv2qhziL+nI9ZWu2mAWNRJNwY9XbUAnXoBFIWM
# HsYaZ4OTD880hmfrYi7kXtlsxw5dZSN5uD9W7sHYarxas1cRYQixglWlrH1OuhJT
# jCRi8aRUSe49GibbfOWislADX1aKVnOJfEXdj8+EHL/Ilb+ytZMo4BAGz0vDwROA
# U9cMW4SQ8H61UeWris0BJPZXDqrTvneq92FeXB8VlbnbAW1txxLa4y5N9TERAn+l
# Kk2klRf12GeTDdF/1ldZ/qkr9IRVM86ItVqi6eszQTQ7USeKZLbKBHdFYOqmntl2
# PemoUdQ/7dFzSgB7xJufD6GCAyAwggMcBgkqhkiG9w0BCQYxggMNMIIDCQIBATB3
# MGMxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjE7MDkGA1UE
# AxMyRGlnaUNlcnQgVHJ1c3RlZCBHNCBSU0E0MDk2IFNIQTI1NiBUaW1lU3RhbXBp
# bmcgQ0ECEAp6SoieyZlCkAZjOE2Gl50wDQYJYIZIAWUDBAIBBQCgaTAYBgkqhkiG
# 9w0BCQMxCwYJKoZIhvcNAQcBMBwGCSqGSIb3DQEJBTEPFw0yMjA0MDUyMjQxNTla
# MC8GCSqGSIb3DQEJBDEiBCAEjrpA9izhfTiztOv3DaIEkxEPBqFLmNfSVQ1y2NNS
# 5zANBgkqhkiG9w0BAQEFAASCAgCjAVrHD95ecx6doO7VbX59kQWHj9G5oC0JVmtw
# BUfEeZptaQYx3afw+E9l/MB9UQNdXaNr7djkmBRqTe4Kj4ozFOlUQP4IwQ8Fd6Jg
# hKptKXxnC0oQg9/RlJi2WB0U3A+U2qKD7I+8MRJcv1AIJMuMRSHbfOaQ4RcEaHh7
# w1iFCv0Cc1hwNJBN9P5RwSds2gDml2W8MBVsktWBkLDlk6wQDKNVwQLEhJkSkM+H
# Rsj6Nw3ENbFivukdKlGGUinMEl4+95Nkf+geHBDMv1GoSg8HomN4rfmMf1M6ylfK
# lXev46fevDInIsrzAfwKyrrCbuwvZJnWvpV14Np64VGltgTHu4EZRnnnZyOoRlKG
# 59QHBtc8DkhsGSQgzUu3BrAhCblNG8Nxbw0IpYzCeT0cttAMEuLtBre5V16WtF+9
# Ul1ohvmjttgzUJ/JQQYg3ixwnd4WUf9ZSDxQRMm4I30LzZsYyxXiTSLfeWizzPJG
# U9Xk1/Lzjw9FbqDRh1qESUynU5MRBzjoyzhSAd0UxuSazBlJuKVKYo1/96cCb4th
# bHKQyExnbktKqHpw4B4Ckd1L3fdD17TW0eT7gkYFPnTSZzqkl6+0r/RLBXhmyThi
# w7+nfga4qXz0hWKGjtwo1a0BgFe29VWOZW8KdgbxT6Q741m+BcObGLf/5dk6/ztl
# PXWKWQ==
# SIG # End signature block
