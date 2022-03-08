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

# SIG # Begin signature block
# MIISSwYJKoZIhvcNAQcCoIISPDCCEjgCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUANOE19hvUU0v0nfzc9mtrjnF
# swWggg2VMIIDWjCCAkKgAwIBAgIQVE1UkhnbkL1Em0JU5EuTajANBgkqhkiG9w0B
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
# AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUBOnC7arACtXsDkmf
# peSFhvjWDa0wDQYJKoZIhvcNAQEBBQAEggEAfb7FYapd27+0I9+RwllGHi77PJ9v
# S4WaDSZCQn8UxvhjcCvqbKvhqZJIZXJNoL0BcikbntA1Qdyv/uRgVwkiOAHcQIpm
# xgkKLrjbgh/b/pHXC/rxM8f2T1qcBebrT18IZbe5JZcjWapAlRzezL/TStJaz9Z+
# 1xuaQBfqNzhpz5SCotJiNOo4C+xacfYeNg9BYPBRkLWlxU2MFCNCsd5v8Pvnn0gj
# xoA2x0sgRCpLmjuy4/XlL1mSusDZYmoM8SscFnSGO0pTciSnzC96swdoxBsBHJ9E
# 2U1JA2UMl+3YU7a/rkEim0v35Ir4zT8rWJsC7ZuVaL2vWE4UyJu1En2hOqGCAjAw
# ggIsBgkqhkiG9w0BCQYxggIdMIICGQIBATCBhjByMQswCQYDVQQGEwJVUzEVMBMG
# A1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMTEw
# LwYDVQQDEyhEaWdpQ2VydCBTSEEyIEFzc3VyZWQgSUQgVGltZXN0YW1waW5nIENB
# AhANQkrgvjqI/2BAIc4UAPDdMA0GCWCGSAFlAwQCAQUAoGkwGAYJKoZIhvcNAQkD
# MQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMjIwMzA4MTkzODQ5WjAvBgkq
# hkiG9w0BCQQxIgQgJAoyiQ/pENkRAUM4rwTBJe7LoauorhDedwWpzh0YAuAwDQYJ
# KoZIhvcNAQEBBQAEggEAFCXy+yGMw1oXQgIlo8ujLamyALUH5WE1UqjDC5y4Edhj
# zkE1Q2Ig19KapOg/j5wcQVmR5H7QGgwcKwdyPhbNUCJ/YbhOcBtnA8qfLu003tyF
# grvQCenIpUzgQl1crqq5gsLxVs74UswO2iEGxr4t1LeDw/xvFM7tl1unZd7u46qv
# 8nnY29MsLWRopKdTqyK5lPM999TpfZkFRSIqYMjSUrpAXZgGdOXiMXkhgiY+6BaB
# kNFocN5S6+fAx7L65lPNqssx/Ae5EWi+zzeNieHrnf9vKB+tE7e1XmIyFeOhONqO
# o6lqWHgvKgLKR3wsZ3kd93n+0/WWt7o/xeK4N+8ijg==
# SIG # End signature block
