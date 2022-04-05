# Download and install Chocolatey nupkg from an OData (HTTP/HTTPS) url such as Artifactory, Nexus, ProGet (all of these are recommended for organizational use), or Chocolatey.Server (great for smaller organizations and POCs)
# This is where you see the top level API - with xml to Packages - should look nearly the same as https://community.chocolatey.org/api/v2/
# If you are using Nexus, always add the trailing slash or it won't work
# === EDIT HERE ===
$packageRepo = 'https://choco.aolccbc.com/'

# If the above $packageRepo repository requires authentication, add the username and password here. Otherwise these leave these as empty strings.
$repoUsername = ''    # this must be empty is NOT using authentication
$repoPassword = ''    # this must be empty if NOT using authentication

# Determine unzipping method
# 7zip is the most compatible, but you need an internally hosted 7za.exe.
# Make sure the version matches for the arguments as well.
# Built-in does not work with Server Core, but if you have PowerShell 5
# it uses Expand-Archive instead of COM
$unzipMethod = 'builtin'
#$unzipMethod = '7zip'
#$7zipUrl = 'https://chocolatey.org/7za.exe' (download this file, host internally, and update this to internal)

# === ENVIRONMENT VARIABLES YOU CAN SET ===
# Prior to running this script, in a PowerShell session, you can set the
# following environment variables and it will affect the output

# - $env:ChocolateyEnvironmentDebug = 'true' # see output
# - $env:chocolateyIgnoreProxy = 'true' # ignore proxy
# - $env:chocolateyProxyLocation = '' # explicit proxy
# - $env:chocolateyProxyUser = '' # explicit proxy user name (optional)
# - $env:chocolateyProxyPassword = '' # explicit proxy password (optional)

# === NO NEED TO EDIT ANYTHING BELOW THIS LINE ===
# Ensure we can run everything
Set-ExecutionPolicy Bypass -Scope Process -Force;

# If the repository requires authentication, create the Credential object
if ((-not [string]::IsNullOrEmpty($repoUsername)) -and (-not [string]::IsNullOrEmpty($repoPassword))) {
$securePassword = ConvertTo-SecureString $repoPassword -AsPlainText -Force
$repoCreds = New-Object System.Management.Automation.PSCredential ($repoUsername, $securePassword)
}

$searchUrl = ($packageRepo.Trim('/'), 'Packages()?$filter=(Id%20eq%20%27chocolatey%27)%20and%20IsLatestVersion') -join '/'

# Reroute TEMP to a local location
New-Item $env:ALLUSERSPROFILE\choco-cache -ItemType Directory -Force
$env:TEMP = "$env:ALLUSERSPROFILE\choco-cache"

$localChocolateyPackageFilePath = Join-Path $env:TEMP 'chocolatey.nupkg'
$ChocoInstallPath = "$($env:SystemDrive)\ProgramData\Chocolatey\bin"
$env:ChocolateyInstall = "$($env:SystemDrive)\ProgramData\Chocolatey"
$env:Path += ";$ChocoInstallPath"
$DebugPreference = 'Continue';

# PowerShell v2/3 caches the output stream. Then it throws errors due
# to the FileStream not being what is expected. Fixes "The OS handle's
# position is not what FileStream expected. Do not use a handle
# simultaneously in one FileStream and in Win32 code or another
# FileStream."
function Fix-PowerShellOutputRedirectionBug {
$poshMajorVerion = $PSVersionTable.PSVersion.Major

if ($poshMajorVerion -lt 4) {
try{
# http://www.leeholmes.com/blog/2008/07/30/workaround-the-os-handles-position-is-not-what-filestream-expected/ plus comments
$bindingFlags = [Reflection.BindingFlags] "Instance,NonPublic,GetField"
$objectRef = $host.GetType().GetField("externalHostRef", $bindingFlags).GetValue($host)
$bindingFlags = [Reflection.BindingFlags] "Instance,NonPublic,GetProperty"
$consoleHost = $objectRef.GetType().GetProperty("Value", $bindingFlags).GetValue($objectRef, @())
[void] $consoleHost.GetType().GetProperty("IsStandardOutputRedirected", $bindingFlags).GetValue($consoleHost, @())
$bindingFlags = [Reflection.BindingFlags] "Instance,NonPublic,GetField"
$field = $consoleHost.GetType().GetField("standardOutputWriter", $bindingFlags)
$field.SetValue($consoleHost, [Console]::Out)
[void] $consoleHost.GetType().GetProperty("IsStandardErrorRedirected", $bindingFlags).GetValue($consoleHost, @())
$field2 = $consoleHost.GetType().GetField("standardErrorWriter", $bindingFlags)
$field2.SetValue($consoleHost, [Console]::Error)
} catch {
Write-Output 'Unable to apply redirection fix.'
}
}
}

Fix-PowerShellOutputRedirectionBug

# Attempt to set highest encryption available for SecurityProtocol.
# PowerShell will not set this by default (until maybe .NET 4.6.x). This
# will typically produce a message for PowerShell v2 (just an info
# message though)
try {
# Set TLS 1.2 (3072), then TLS 1.1 (768), then TLS 1.0 (192)
# Use integers because the enumeration values for TLS 1.2 and TLS 1.1 won't
# exist in .NET 4.0, even though they are addressable if .NET 4.5+ is
# installed (.NET 4.5 is an in-place upgrade).
[System.Net.ServicePointManager]::SecurityProtocol = 3072 -bor 768 -bor 192
} catch {
Write-Output 'Unable to set PowerShell to use TLS 1.2 and TLS 1.1 due to old .NET Framework installed. If you see underlying connection closed or trust errors, you may need to upgrade to .NET Framework 4.5+ and PowerShell v3+.'
}

function Get-Downloader {
param (
[string]$url
)
$downloader = new-object System.Net.WebClient

$defaultCreds = [System.Net.CredentialCache]::DefaultCredentials
if (Test-Path -Path variable:repoCreds) {
Write-Debug "Using provided repository authentication credentials."
$downloader.Credentials = $repoCreds
} elseif ($defaultCreds -ne $null) {
Write-Debug "Using default repository authentication credentials."
$downloader.Credentials = $defaultCreds
}

$ignoreProxy = $env:chocolateyIgnoreProxy
if ($ignoreProxy -ne $null -and $ignoreProxy -eq 'true') {
Write-Debug 'Explicitly bypassing proxy due to user environment variable.'
$downloader.Proxy = [System.Net.GlobalProxySelection]::GetEmptyWebProxy()
} else {
# check if a proxy is required
$explicitProxy = $env:chocolateyProxyLocation
$explicitProxyUser = $env:chocolateyProxyUser
$explicitProxyPassword = $env:chocolateyProxyPassword
if ($explicitProxy -ne $null -and $explicitProxy -ne '') {
# explicit proxy
$proxy = New-Object System.Net.WebProxy($explicitProxy, $true)
if ($explicitProxyPassword -ne $null -and $explicitProxyPassword -ne '') {
$passwd = ConvertTo-SecureString $explicitProxyPassword -AsPlainText -Force
$proxy.Credentials = New-Object System.Management.Automation.PSCredential ($explicitProxyUser, $passwd)
}

Write-Debug "Using explicit proxy server '$explicitProxy'."
$downloader.Proxy = $proxy

} elseif (!$downloader.Proxy.IsBypassed($url)) {
# system proxy (pass through)
$creds = $defaultCreds
if ($creds -eq $null) {
Write-Debug 'Default credentials were null. Attempting backup method'
$cred = get-credential
$creds = $cred.GetNetworkCredential();
}

$proxyaddress = $downloader.Proxy.GetProxy($url).Authority
Write-Debug "Using system proxy server '$proxyaddress'."
$proxy = New-Object System.Net.WebProxy($proxyaddress)
$proxy.Credentials = $creds
$downloader.Proxy = $proxy
}
}

return $downloader
}

function Download-File {
param (
[string]$url,
[string]$file
)
$downloader = Get-Downloader $url
$downloader.DownloadFile($url, $file)
}

function Download-Package {
param (
[string]$packageODataSearchUrl,
[string]$file
)
$downloader = Get-Downloader $packageODataSearchUrl

Write-Output "Querying latest package from $packageODataSearchUrl"
[xml]$pkg = $downloader.DownloadString($packageODataSearchUrl)
$packageDownloadUrl = $pkg.feed.entry.content.src

Write-Output "Downloading $packageDownloadUrl to $file"
$downloader.DownloadFile($packageDownloadUrl, $file)
}

function Install-ChocolateyFromPackage {
param (
[string]$chocolateyPackageFilePath = ''
)

if ($chocolateyPackageFilePath -eq $null -or $chocolateyPackageFilePath -eq '') {
throw "You must specify a local package to run the local install."
}

if (!(Test-Path($chocolateyPackageFilePath))) {
throw "No file exists at $chocolateyPackageFilePath"
}

$chocTempDir = Join-Path $env:TEMP "chocolatey"
$tempDir = Join-Path $chocTempDir "chocInstall"
if (![System.IO.Directory]::Exists($tempDir)) {[System.IO.Directory]::CreateDirectory($tempDir)}
$file = Join-Path $tempDir "chocolatey.zip"
Copy-Item $chocolateyPackageFilePath $file -Force

# unzip the package
Write-Output "Extracting $file to $tempDir..."
if ($unzipMethod -eq '7zip') {
$7zaExe = Join-Path $tempDir '7za.exe'
if (-Not (Test-Path ($7zaExe))) {
Write-Output 'Downloading 7-Zip commandline tool prior to extraction.'
# download 7zip
Download-File $7zipUrl "$7zaExe"
}

$params = "x -o`"$tempDir`" -bd -y `"$file`""
# use more robust Process as compared to Start-Process -Wait (which doesn't
# wait for the process to finish in PowerShell v3)
$process = New-Object System.Diagnostics.Process
$process.StartInfo = New-Object System.Diagnostics.ProcessStartInfo($7zaExe, $params)
$process.StartInfo.RedirectStandardOutput = $true
$process.StartInfo.UseShellExecute = $false
$process.StartInfo.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden
$process.Start() | Out-Null
$process.BeginOutputReadLine()
$process.WaitForExit()
$exitCode = $process.ExitCode
$process.Dispose()

$errorMessage = "Unable to unzip package using 7zip. Perhaps try setting `$env:chocolateyUseWindowsCompression = 'true' and call install again. Error:"
switch ($exitCode) {
0 { break }
1 { throw "$errorMessage Some files could not be extracted" }
2 { throw "$errorMessage 7-Zip encountered a fatal error while extracting the files" }
7 { throw "$errorMessage 7-Zip command line error" }
8 { throw "$errorMessage 7-Zip out of memory" }
255 { throw "$errorMessage Extraction cancelled by the user" }
default { throw "$errorMessage 7-Zip signalled an unknown error (code $exitCode)" }
}
} else {
if ($PSVersionTable.PSVersion.Major -lt 5) {
try {
$shellApplication = new-object -com shell.application
$zipPackage = $shellApplication.NameSpace($file)
$destinationFolder = $shellApplication.NameSpace($tempDir)
$destinationFolder.CopyHere($zipPackage.Items(),0x10)
} catch {
throw "Unable to unzip package using built-in compression. Set `$env:chocolateyUseWindowsCompression = 'false' and call install again to use 7zip to unzip. Error: `n $_"
}
} else {
Expand-Archive -Path "$file" -DestinationPath "$tempDir" -Force
}
}

# Call Chocolatey install
Write-Output 'Installing chocolatey on this machine'
$toolsFolder = Join-Path $tempDir "tools"
$chocInstallPS1 = Join-Path $toolsFolder "chocolateyInstall.ps1"

& $chocInstallPS1

Write-Output 'Ensuring chocolatey commands are on the path'
$chocInstallVariableName = 'ChocolateyInstall'
$chocoPath = [Environment]::GetEnvironmentVariable($chocInstallVariableName)
if ($chocoPath -eq $null -or $chocoPath -eq '') {
$chocoPath = 'C:\ProgramData\Chocolatey'
}

$chocoExePath = Join-Path $chocoPath 'bin'

if ($($env:Path).ToLower().Contains($($chocoExePath).ToLower()) -eq $false) {
$env:Path = [Environment]::GetEnvironmentVariable('Path',[System.EnvironmentVariableTarget]::Machine);
}

Write-Output 'Ensuring chocolatey.nupkg is in the lib folder'
$chocoPkgDir = Join-Path $chocoPath 'lib\chocolatey'
$nupkg = Join-Path $chocoPkgDir 'chocolatey.nupkg'
if (!(Test-Path $nupkg)) {
Write-Output 'Copying chocolatey.nupkg is in the lib folder'
if (![System.IO.Directory]::Exists($chocoPkgDir)) { [System.IO.Directory]::CreateDirectory($chocoPkgDir); }
Copy-Item "$file" "$nupkg" -Force -ErrorAction SilentlyContinue
}
}

# Idempotence - do not install Chocolatey if it is already installed
if (!(Test-Path $ChocoInstallPath)) {
# download the package to the local path
if (!(Test-Path $localChocolateyPackageFilePath)) {
Download-Package $searchUrl $localChocolateyPackageFilePath
}

# Install Chocolatey
Install-ChocolateyFromPackage $localChocolateyPackageFilePath

}



#DONT RUIN ME
# SIG # Begin signature block
# MIIWgAYJKoZIhvcNAQcCoIIWcTCCFm0CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUoIdpdd0G7OZ/6D668/fiMHJB
# sCigghDaMIIDWjCCAkKgAwIBAgIQVE1UkhnbkL1Em0JU5EuTajANBgkqhkiG9w0B
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
# 9w0BCQQxFgQUPwJ//G/rJPSvFKryJ9dnZyMjmw8wDQYJKoZIhvcNAQEBBQAEggEA
# WdX3ssEorHALLhyGXVRPeYvMEvjwlF2UVw4GSawu8NtC3Vbkr5bnt2bz1YzYuUi5
# UQe6mAVpTVa5i3+m4U57bIFG3kMGJjDhaIdUD4hF9KhRQ/xVDBZt3+bLEYb1J5MK
# mVQ0yfRg2B6vBHRsM5QXVW/u09n4Ls3J1gIubz5oAXQYqFleCOkzIA81MbrccD/K
# El78rP/NTPOudi0Vg0FAltjtgutWtqamchRyvOyQpgopxlWws/lQwq56MGNe+P9x
# fiIVKuqGPgZ/CevWKswFhRX3Vf9Dl4yxAgfrpeChhizrSwInmeuoyURnq2VF2h9Z
# XBsaJC1We4DIJC4tCM1BrqGCAyAwggMcBgkqhkiG9w0BCQYxggMNMIIDCQIBATB3
# MGMxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjE7MDkGA1UE
# AxMyRGlnaUNlcnQgVHJ1c3RlZCBHNCBSU0E0MDk2IFNIQTI1NiBUaW1lU3RhbXBp
# bmcgQ0ECEAp6SoieyZlCkAZjOE2Gl50wDQYJYIZIAWUDBAIBBQCgaTAYBgkqhkiG
# 9w0BCQMxCwYJKoZIhvcNAQcBMBwGCSqGSIb3DQEJBTEPFw0yMjA0MDUyMjQxNTVa
# MC8GCSqGSIb3DQEJBDEiBCB/6daq/+tzPLgQ21rtT4kOIiI5prYBFBHBe24Cphfz
# +jANBgkqhkiG9w0BAQEFAASCAgCMlH2Cyc0ezZA5tuJ0t395TipJhGoZnvlCWsw6
# VOaFu0CXc0AJeUD4JJqalkPW8kR0UcDe6kksRIi6JLTAFPJS6wbPvT2t2CNBTPBv
# HaJHT98Mc/yEAhdX5Y7xjnd+M244Sk94H6tW+P7GYbIy55MXQ087H8ZKkGZWzz+V
# EJRKs2wkCdzvccLz60Gayb6ZC1xVJzL0/rmCQI1d7nmZips3bmrzcwhJ42qM64zh
# SUqnjg05Lu+C9S9qgDsuja5ngVxVTDzuiL2AzRiuBagPJVn8EdeZx4pXbN4Vd0fv
# 3/Z7hWuqHexXk2p2MYSLhKpFTvE9YUqI8MpQrZcWMIg1DdpOfTrwONpUoEaSwaHK
# pT9tqj3tJVEhSIZlbDSnW+MGHxL7I3IW1N1AOR6N+qcpVXytn0BOCw0+cSVPFs7U
# CZ6WhQD1TQz7XhbJb4PPvLdRztE8z+6uCjtHGQlFwUro5TLEYn0+8kjRh9horGvE
# Kwtq86tghSdIqA89iWtgvZWauqghMcsQZyAFRAfFtkDj/KMw8Cuz0z/zXIZhJeJB
# bp7iQUOUJdtjLPLNGjyjNeW3sNhClAZLZXXol+aBbTSCazIOQqUDeRKH1M92mx2A
# heEzSJ79VKJjWiNfektvowhqb1jRV7r9TMjc5glm6jtrP9YI1xTt3FBqQ9qWe1gF
# rlYbsA==
# SIG # End signature block
