# Script to copy companies teams backgrounds to users %appdata%\Microsoft\Teams\Backgrounds.
# Created by: Remy Kuster
# Website: www.iamsysadmin.eu
# Modified by: Remco Janssen (19-01-2021)
# Creation date: 13-01-2021

# Create variables

$sourcefile = "https://github.com/fireball8931/AOLCCApps/raw/master/aolccwallpaper.jpg" # Set the share and folder where you put the custom backgrounds
$outfile = "$Uploadfolder\aolccwallpaper.jpg"
$TeamsStarted = "$env:APPDATA\Microsoft\Teams"
$DirectoryBGToCreate = "$env:APPDATA\Microsoft\Teams\Backgrounds"
$Uploadfolder = "$env:APPDATA\Microsoft\Teams\Backgrounds\Uploads"
$Logfile = "$env:LOCALAPPDATA\Logs\BG-copy.log"
$Logfilefolder = "$env:LOCALAPPDATA\Logs"

# Create logfile and function

# Check if %localappdata%\Logs is present, if not create folder and logfile

if (!(Test-Path -LiteralPath $Logfilefolder -PathType container)) 
    {
    
        try 
            {
                New-Item -Path $Logfilefolder -ItemType Directory -ErrorAction Stop | Out-Null #-Force
                New-Item -Path $Logfilefolder -Name "BG-copy.log" -ItemType File -ErrorAction Stop | Out-Null #-Force

                Start-Sleep -s 10

            }

        catch 

            {
                Write-Error -Message "Unable to create directory '$Logfilefolder' . Error was: $_" -ErrorAction Stop    
            }

    "Successfully created directory '$Logfilefolder' ."

    }

else 

    {
        "Directory '$Logfilefolder' already exist"
    }

# Clear the logfile before starting

Clear-Content $Logfile

# Create the logwrite function

Function LogWrite
{
   Param ([string]$logstring)
   $Stamp = (Get-Date).toString("dd/MM/yyy HH:mm:ss")
    $Line = "$Stamp $logstring"
 
   Add-content $Logfile -value $Line
}

# Check if teams is started once before for current user

if ( (Test-Path -LiteralPath $TeamsStarted) ) 
    { 
        logwrite "Teams started once before by the current user."
    }

else

    {
        logwrite "Teams has never been started by user"
        Exit 1
    }

# Check if %appdata%\Microsoft\Teams\Background is present, if not create folder

if (!(Test-Path -LiteralPath $DirectoryBGToCreate -PathType container)) 
    {
    
        try 
            {
                New-Item -Path $DirectoryBGToCreate -ItemType Directory -ErrorAction Stop | Out-Null #-Force
            }
        catch 
            {
                Write-Error -Message "Unable to create directory '$DirectoryBGToCreate' . Error was: $_" -ErrorAction Stop    
            }

    logwrite "Successfully created directories '$DirectoryBGToCreate' ."
    }

else 
    {
        logwrite "Directory '$DirectoryBGToCreate' already exist"
    }

# Check if %appdata%\Microsoft\Teams\Background\Uploads is present, if not create folder

if (!(Test-Path -LiteralPath $Uploadfolder -PathType container)) 
    {
    
        try 
            {
                New-Item -Path $Uploadfolder -ItemType Directory -ErrorAction Stop | Out-Null #-Force
            }
        catch 
            {
                Write-Error -Message "Unable to create directory '$Uploadfolder' . Error was: $_" -ErrorAction Stop    
            }

     logwrite "Successfully created directories '$Uploadfolder' ."
    }

else 
    {
        logwrite "Directory '$Uploadfolder' already exist"
    }

# Check if machine is connected to your corporate network

#$getoutput = (Test-Connection -ComputerName (hostname) -Count 1).IPV4Address.IPAddressToString # process active IP-address
#$getoutput = Get-NetIPAddress -AddressFamily IPv4 | Out-String -stream | Select-String -Pattern "IPAddress" # process IP-address list

# You can multiple adres ranges if your company has got vpn, wireless and physical different subnets. 
# This because we don't want to start the copy action from the share if the device is not connected to the corperate network.
        logwrite "Start copy action of uploads folder from share"
        Invoke-WebRequest -uri $sourcefile -outfile $outfile    
       


# SIG # Begin signature block
# MIISSwYJKoZIhvcNAQcCoIISPDCCEjgCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUJvK47Ari2ZYY+DKzFJ6bN4kG
# cIeggg2VMIIDWjCCAkKgAwIBAgIQVE1UkhnbkL1Em0JU5EuTajANBgkqhkiG9w0B
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
# AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUhM8hPmobFqPUEwv0
# wEU1QxKS2BQwDQYJKoZIhvcNAQEBBQAEggEATqOWDqcoVk2MzGc4nhL/OwOUKLvJ
# iHqkq3DTZzVssBcE7ubXpW3FhLuCs5SuvASuqkQq989TznUNUbtM9cem0RTlwLeB
# j8IQqok/TuIQTnvNukBGy9KwBpoVPlIBuKGjP5mUMRVzNufG9l3lSUblRvPqk2qD
# FjZoWKWwu6+NkSc2K3b1b9bexMhCxCBN8J4Zk9Ge/65VQ8XCopYILdKgMY7gQrXU
# XU6Q8etJPlCi0XJuuk6/A9/STmvJYDmDfLbwi31JY/5THANsIoye4SKKzOuQLz/m
# u4LPZJ3tvjRREwviz50dlC8iBvsSBTotlRUHv3R8/OpqdA55ZuVnbrLI2aGCAjAw
# ggIsBgkqhkiG9w0BCQYxggIdMIICGQIBATCBhjByMQswCQYDVQQGEwJVUzEVMBMG
# A1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMTEw
# LwYDVQQDEyhEaWdpQ2VydCBTSEEyIEFzc3VyZWQgSUQgVGltZXN0YW1waW5nIENB
# AhANQkrgvjqI/2BAIc4UAPDdMA0GCWCGSAFlAwQCAQUAoGkwGAYJKoZIhvcNAQkD
# MQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMjIwMzI4MjIyMTA4WjAvBgkq
# hkiG9w0BCQQxIgQgxGHIxoKb8IsVG8rqY1XhPu2hpB9vyzjXb1qM7s6JXk4wDQYJ
# KoZIhvcNAQEBBQAEggEAajeyv+S3EJVpDUwFfL8EOLwfODQs7bKMtUId7eR1fk0w
# b8NkLz8Wz8bCEvM0IKMMVypiEImPvg2jusdhSPFdiebeHQOUbKbI+QY4KQAFMamY
# xISrgQPHHdY+PNDNv8wECgCrOWx+VllhQzdibv1bujdDoyhHF4yda93iTB83VDRY
# su9Fp5nLvGJqQDG0svIR7Jc32u/2/8JNWlpSyrVBSFxfXQZxcYLgLuBGzApPocWR
# vDGLsK0dVSkjsUVq5kwDzm1BpjFVRsQYzR+m6MG+VIQL+u8T3II0yWjRBOXHCIgx
# PV2kqOw0tznl5CfTQspgLDfkX4ZWfdzqv4Yj+it9nA==
# SIG # End signature block
