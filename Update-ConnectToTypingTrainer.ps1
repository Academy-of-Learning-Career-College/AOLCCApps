#Requires -RunAsAdministrator
Install-Module PSShortcut -Force


$github = 'https://raw.githubusercontent.com/fireball8931/AOLCCApps/master/Typing'
$externalip = (Invoke-WebRequest -Uri 'http://ifconfig.me/ip' -UseBasicParsing).Content
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
#$tticonsrc = ${env:ProgramFiles(x86)} + '\ACMEPro2011\ACME.exe'
$ttshortcutname = 'Connect to Typing Trainer.lnk'
$ttshortcutdest = $env:ALLUSERSPROFILE + '\Microsoft\Windows\Start Menu\Programs\' + $ttshortcutname
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
Set-Shortcut -TargetPath $typingbatdest -FilePath $ttshortcutdest
# SIG # Begin signature block
# MIISSwYJKoZIhvcNAQcCoIISPDCCEjgCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUisaJLSCuiHu++LZiSIszGWII
# WsCggg2VMIIDWjCCAkKgAwIBAgIQVE1UkhnbkL1Em0JU5EuTajANBgkqhkiG9w0B
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
# AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUpGdkFmuJKSePeUjk
# K3vMosSD+FwwDQYJKoZIhvcNAQEBBQAEggEAOeYeFLH/ypZANLdO1CgSyWwOlqf9
# FltGIC/X6kXwiYyMlpTJtKmyL4QVSYnaxk3RXOfoJvjcMzb26U6fu7+hFNlYxKAV
# mmS1WmSlWR5F3dz+Uj6lkYAOcrbCE+YrI4Yt3s/PdwpyJ2qqLsaXruZVjkd1L8CF
# AmJ7ulKFqXtqfn2gIBuFtdbW+tHORwgRG9PSEHXVG0wr294dQkDxv8I9Mf8/CIPr
# E67qBGOoMykXvfXFWGU1r4Bz2RVcEaiZm2G51sniuidGsYSpnEQP+AgeLro4R0wN
# FUcHHimvko2S6ebs3UGgSjRYpLq6Sy65UxQB9/tsb7L4qQkxWly1+/7plqGCAjAw
# ggIsBgkqhkiG9w0BCQYxggIdMIICGQIBATCBhjByMQswCQYDVQQGEwJVUzEVMBMG
# A1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMTEw
# LwYDVQQDEyhEaWdpQ2VydCBTSEEyIEFzc3VyZWQgSUQgVGltZXN0YW1waW5nIENB
# AhANQkrgvjqI/2BAIc4UAPDdMA0GCWCGSAFlAwQCAQUAoGkwGAYJKoZIhvcNAQkD
# MQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMjIwMzI4MjAxMzE3WjAvBgkq
# hkiG9w0BCQQxIgQgZj/PTfe2vOo/9dwSF9Zg8AcJJjJK7L/HzjDqPs5uuhIwDQYJ
# KoZIhvcNAQEBBQAEggEAk5T1bM2IUfW9R2OtdH8zRXLpOZzIXkPW3JaeO9rhmYK2
# tMn3dchw05Py+Mgrc/UAGc+BFwFN3P+5oGehCU5sWmMkRtAOm+q5WOhAWlW3GVP+
# IRx4Mc8ws8uLEHtIpT/zygjbmWEwRFhTrgUC2heC/VxkEBeASaabjWFbLGy09Ton
# Kjsb7lDUvy83hlMROFYXOTQwJvnwybX5lDyxuD90waRoWguME5ikqXX0hxz3AWjl
# r0oKG84j+aqMz3qfJscUrsNbxOuKZq5uK2n6onMNM/y/gVmta1fctEthLUTETfEo
# S/Z6v+pkwOqt00TIfyTduegiEitjev4QdXkpnZ4m7w==
# SIG # End signature block
