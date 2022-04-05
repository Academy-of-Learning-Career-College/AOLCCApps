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
# MIIWgAYJKoZIhvcNAQcCoIIWcTCCFm0CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUJvK47Ari2ZYY+DKzFJ6bN4kG
# cIegghDaMIIDWjCCAkKgAwIBAgIQVE1UkhnbkL1Em0JU5EuTajANBgkqhkiG9w0B
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
# 9w0BCQQxFgQUhM8hPmobFqPUEwv0wEU1QxKS2BQwDQYJKoZIhvcNAQEBBQAEggEA
# TqOWDqcoVk2MzGc4nhL/OwOUKLvJiHqkq3DTZzVssBcE7ubXpW3FhLuCs5SuvASu
# qkQq989TznUNUbtM9cem0RTlwLeBj8IQqok/TuIQTnvNukBGy9KwBpoVPlIBuKGj
# P5mUMRVzNufG9l3lSUblRvPqk2qDFjZoWKWwu6+NkSc2K3b1b9bexMhCxCBN8J4Z
# k9Ge/65VQ8XCopYILdKgMY7gQrXUXU6Q8etJPlCi0XJuuk6/A9/STmvJYDmDfLbw
# i31JY/5THANsIoye4SKKzOuQLz/mu4LPZJ3tvjRREwviz50dlC8iBvsSBTotlRUH
# v3R8/OpqdA55ZuVnbrLI2aGCAyAwggMcBgkqhkiG9w0BCQYxggMNMIIDCQIBATB3
# MGMxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjE7MDkGA1UE
# AxMyRGlnaUNlcnQgVHJ1c3RlZCBHNCBSU0E0MDk2IFNIQTI1NiBUaW1lU3RhbXBp
# bmcgQ0ECEAp6SoieyZlCkAZjOE2Gl50wDQYJYIZIAWUDBAIBBQCgaTAYBgkqhkiG
# 9w0BCQMxCwYJKoZIhvcNAQcBMBwGCSqGSIb3DQEJBTEPFw0yMjA0MDUyMjQxNTla
# MC8GCSqGSIb3DQEJBDEiBCDEYcjGgpvwixUbyupjVeE+7aGkH2/LONdvWozuzole
# TjANBgkqhkiG9w0BAQEFAASCAgByqINnml5hF5KCOqYvIUs9jeo9ja4FlJD2xbBX
# 3nhzv4k89QMvz+ADwLKMIgO7j6bnay0XOyIqeIUunoOxt++mW7FiPC9bpjYXWVl2
# zUAL1uSPd7r6Dm9vctmy6QMwEjxESvgOyQFJR2m1lsotfO0J59nd3NFUFPiY+mtl
# dr4gJYUEEzq+n2zlixsyFfX17QY0STab9TwDLSgIskHQYXTYE6r5nG3crTgjzLnt
# hNCCemmJKeGG9kYOLfqhhrATUDni5V+yJdVFj1ZvnCPoMy/n+KXL0T9uHW9+fpUm
# 02MbcnQCoWgC0lXFjiwUqwa6HMlwxR6lTXty8RNGTziBREYSeX0xYykAFV7pJvst
# cZxDedeVE/GcuvnT+ZpqWWWLewLV9aTfLsPFNztysqqfjz+KGnxRiZ0EEFSH6Kpf
# Lhu30ErbjuXPBgjaDbp2Z49xHMV5+aXKYN/nCiq4883LAwUUUeJS0qd6l67DG/vt
# DaiC1zLYHl9Fo7lJjRJ6kkkt6+DN/0F9QH8W+Ybqmw310oWigN86Fme+OjV/4A8i
# GVWoNdQ+sa1sdWv6FweiEokulqwUtkc/926NLU4F3OYBFUYCXx3fSUWhTfMtMco5
# fpnwTpNrkq5IuNUA9IFWEQZ55Jb+CnjgZXroWd/Zk1cs9+yg79vidDkA+tpmpm7b
# WSsv1g==
# SIG # End signature block
