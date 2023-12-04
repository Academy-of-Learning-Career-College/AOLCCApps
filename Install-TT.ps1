# Domain name
$d = "pub-ba40a2c327284ac787fcf7379eaa7030.r2.dev"

# Application URLs and version numbers
$a = "acmepro.v216.1.setup.exe"
$t = "typingtrainersetup_v1.68.exe"
$v = "vcredist_x86.exe"
$appUrls = @(
    "https://$d/$v",
    "https://$d/$a",
    "https://$d/$t"
)

# Download and install Visual C++ Redistributable 2010 x86
$vPath = Join-Path $env:TEMP $v
Invoke-WebRequest -Uri $appUrls[0] -OutFile $vPath -UseBasicParsing
$vcProcess = Start-Process -FilePath $vPath -ArgumentList "/q" -PassThru
$vcProcess.WaitForExit()
Remove-Item $vPath

# Activate .NET 3.5 on Windows 10 or 11
Enable-WindowsOptionalFeature -Online -FeatureName "NetFx3" -NoRestart

# Download and install applications from URLs in $appUrls
$args = "/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-"
foreach ($appUrl in $appUrls[1..$appUrls.Length]) {
    $appPath = Join-Path $env:TEMP "app.exe"
    Invoke-WebRequest -Uri $appUrl -OutFile $appPath -UseBasicParsing
    $appProcess = Start-Process -FilePath $appPath -ArgumentList $args -PassThru
    $appProcess.WaitForExit()
    Remove-Item $appPath
}

# Create Internet shortcuts on the desktop
$u1 = "https://my.aolcc.ca"
$u2 = "https://s.aolccbc.com/att"
$dPath = [Environment]::GetFolderPath("Desktop")
$ePath = (Get-AppxPackage -Name Microsoft.MicrosoftEdge).InstallLocation
function Create-Shortcut {
    param (
        [string]$N,
        [string]$T,
        [string]$A
    )

    $p = Join-Path $dPath "$N.lnk"
    $s = (New-Object -ComObject WScript.Shell).CreateShortcut($p)
    $s.TargetPath = Join-Path $ePath "msedge.exe"
    $s.Arguments = $A
    $s.Save()
}

Create-Shortcut -N "My AOLCC" -T $u1 -A ""
Create-Shortcut -N "AOLCCBC ATT" -T $u2 -A ""
