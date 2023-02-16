# Array of URLs to download applications from
$appUrls = @(
    "https://pub-ba40a2c327284ac787fcf7379eaa7030.r2.dev/acmepro.2011.setup.v216.1.exe",
    "https://pub-ba40a2c327284ac787fcf7379eaa7030.r2.dev/typingtrainersetup_v1.68.exe"
)

# Download and install Visual C++ Redistributable 2010 x86
$vcRedistUrl = "https://download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x86.exe"
$vcRedistPath = "$($env:TEMP)\vcredist_x86.exe"
Invoke-WebRequest -Uri $vcRedistUrl -OutFile $vcRedistPath
Start-Process -FilePath $vcRedistPath -ArgumentList "/q" -Wait
Remove-Item $vcRedistPath

# Activate .NET 3.5 on Windows 10 or 11
Enable-WindowsOptionalFeature -Online -FeatureName "NetFx3" -NoRestart

# Download and install applications from URLs in $appUrls
$appInstallArgs = "/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-"
$appInstallPath = "$($env:TEMP)\app.exe"
foreach ($appUrl in $appUrls) {
    Invoke-WebRequest -Uri $appUrl -OutFile $appInstallPath
    Start-Process -FilePath $appInstallPath -ArgumentList $appInstallArgs -Wait
    Remove-Item $appInstallPath
}

# Create Internet shortcuts on the desktop
$url1 = "https://my.aolcc.ca"
$url2 = "https://s.aolccbc.com/att"
$desktopPath = [Environment]::GetFolderPath("Desktop")
$edgePath = (Get-AppxPackage -Name Microsoft.MicrosoftEdge).InstallLocation
$shortcut1Path = "$desktopPath\My AOLCC.lnk"
$shortcut2Path = "$desktopPath\AOLCCBC ATT.lnk"
$shell = New-Object -ComObject WScript.Shell
$shortcut1 = $shell.CreateShortcut($shortcut1Path)
$shortcut1.TargetPath = "$edgePath\msedge.exe"
$shortcut1.Arguments = $url1
$shortcut1.Save()
$shortcut2 = $shell.CreateShortcut($shortcut2Path)
$shortcut2.TargetPath = "$edgePath\msedge.exe"
$shortcut2.Arguments = $url2
$shortcut2.Save()
